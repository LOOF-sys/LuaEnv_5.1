#include <iostream>
#include <windows.h>
#include <TlHelp32.h>
#include <string>
#include <thread>

#pragma warning(disable:4042)

extern "C" {
#include "include/lauxlib.h"
#include "include/lua.h"
#include "include/lualib.h"
#include "include/lapi.h"
#include "include/lfunc.h"
#include "include/lgc.h"
#include "include/lstate.h"
}

HANDLE Console = GetStdHandle(STD_OUTPUT_HANDLE);

void CError(lua_State* L, const char* Msg) {
    lua_pushstring(L, Msg);
    SetConsoleTextAttribute(Console, 12);
    lua_error(L);
    SetConsoleTextAttribute(Console, 7);
}

void CWarn(lua_State* L, const char* Msg) {
    SetConsoleTextAttribute(Console, 14);
    std::cout << Msg << std::endl;
    SetConsoleTextAttribute(Console, 7);
}

/* Ripped header file funcs to elevate permissions */
#pragma region
#define api_checknelems(L, n)	api_check(L, (n) <= (L->top - L->base))
#define api_incr_top(L)   {api_check(L, L->top < L->ci->top); L->top++;}

// get shit funcs
static Table* getcurrenv(lua_State* L) {
    if (L->ci == L->base_ci)  /* no enclosing function? */
        return hvalue(gt(L));  /* use global table as environment */
    else {
        Closure* func = curr_func(L);
        return func->c.env;
    }

}
void luaC_link(lua_State* L, GCObject* o, lu_byte tt) {
    global_State* g = G(L);
    o->gch.next = g->rootgc;
    g->rootgc = o;
    o->gch.marked = luaC_white(g);
    o->gch.tt = tt;
}
Closure* luaF_newLclosure(lua_State* L, int nelems, Table* e) {
    Closure* c = cast(Closure*, luaM_malloc(L, sizeLclosure(nelems)));
    luaC_link(L, obj2gco(c), LUA_TFUNCTION);
    c->l.isC = 0;
    c->l.env = e;
    c->l.nupvalues = cast_byte(nelems);
    while (nelems--) c->l.upvals[nelems] = NULL;
    return c;
}
extern void lua_pushlclosure(lua_State* L, LClosure fn, int n) {
    Closure* cl;
    lua_lock(L);
    //luaC_checkGC(L);
    api_checknelems(L, n);
    cl = luaF_newLclosure(L, n, getcurrenv(L));
    cl->l = fn;
    L->top -= n;
    while (n--)
        setobj2n(L, &cl->l.p->k[n], L->top + n);
    setclvalue(L, L->top, cl);
    lua_assert(iswhite(obj2gco(cl)));
    api_incr_top(L);
    lua_unlock(L);
}

#pragma endregion Internal Lua Functions
/* ================================================= */

void* lua_tofunction(lua_State* L, int stackn) {
    return (Closure*)lua_topointer(L, stackn);
}

bool CheckLua(lua_State* L, int r) {
    if (r != NULL) {
        std::string error = lua_tostring(L, -1);
        std::cout << error << std::endl;
        return false;
    }
    
    return true;
}

// Functions
#pragma region

static int newcclosure(lua_State* L) {
    if (lua_iscfunction(L, 1)) {
        Closure* Function = (Closure*)lua_tofunction(L, 1);

        CClosure NewFunc = Function->c;
        lua_pushcclosure(L, NewFunc.f, 0);
        return 1;
    }
    if (lua_isfunction(L, 1)) {
        LClosure Function = ((Closure*)lua_tofunction(L, 1))->l;
        lua_pushlclosure(L, Function, 0);
        return 1;
    }
    return 0;
}


static int is_c_function(lua_State* L) {
    if (lua_iscfunction(L, 1)) {
        lua_pushboolean(L, true);
        return 1;
    }
    if (lua_isfunction(L, 1)) {
        lua_pushboolean(L, false);
        return 1;
    }
    return 0;
}

static int hookfunction(lua_State* L) {
    if (lua_isfunction(L,1)) {
        if (lua_iscfunction(L, 2)) {
            Closure* FirstFunc = (Closure*)lua_tofunction(L, 1);
            Closure* TempPtr = (Closure*)lua_tofunction(L, 2);

            CClosure LFunc = FirstFunc->c;
            lua_pushcclosure(L, LFunc.f, 0);

            if (FirstFunc && TempPtr != 0 || NULL) {
                FirstFunc->l = TempPtr->l;
                FirstFunc->c.f = TempPtr->c.f;
            }
            else {
                CError(L, "cannot set a non-function value");
            }
            return 1;
        }
        if (lua_isfunction(L, 2)) {
            Closure* FirstFunc = (Closure*)lua_tofunction(L,1);
            Closure* TempPtr = (Closure*)lua_tofunction(L, 2);

            LClosure LFunc = FirstFunc->l;
            lua_pushlclosure(L, LFunc, 0);

            if (FirstFunc && TempPtr != 0 || NULL) {
                FirstFunc->l = TempPtr->l;
                FirstFunc->c.f = TempPtr->c.f;
            }
            else {
            CError(L, "cannot set a non-function value");
            }
            return 1;
        }
    }
    return 0;
}

double Ticked = 0;
int StartTick() {
    while (true) {
        Sleep(100);
        Ticked = Ticked + .1;
    }
}
static int tick(lua_State* L) {
    lua_pushnumber(L, Ticked);
    return 1;
}
static int loadstring(lua_State* L) {
    if (lua_isstring(L, 1)) {
        if (lua_isstring(L, 2)) {
            if (lua_tostring(L, 2) == "%e") {

            }
        }
        const char* Command = lua_tostring(L, 1);
        luaL_dostring(L, Command);
        lua_pushboolean(L, 1);
        return 1;
    }
    CError(L, "[!] Argument #1 in \"loadstring\" was incorrect, expected string");
    return 0;
}

static int getrawmetatable(lua_State* L) {
    if (lua_istable(L, 1)) {
        lua_getmetatable(L, 1);
        if (!lua_istable(L, -1)) {
            return 0;
        }
    }
    return 1;
}

static int ReadOnlyIndex(lua_State* L) {
    CWarn(L, "attempt to modify a readonly table");
    return 0;
}

static int setreadonly(lua_State* L) {
    if (lua_istable(L, 1) && lua_isboolean(L,2)) {
        lua_newtable(L);
        if (lua_toboolean(L, 2) == true) {
            lua_pushcclosure(L, ReadOnlyIndex, 1);
            lua_setfield(L, -3, "__newindex");
            lua_pushstring(L, "readonly");
            lua_setfield(L, -3, "__metatable");
            lua_settop(L, 1);
            lua_setmetatable(L, -3);
            lua_pushboolean(L, 1);
        }
        else {
            lua_pushstring(L, "default metatable");
            lua_setfield(L, -2, "__metatable");
            lua_getmetatable(L, 1);
            *(Table*)lua_topointer(L, -1) = *(Table*)lua_topointer(L, -2);
            lua_pushboolean(L, 1);
        }
        return 1;
    }
    lua_pushboolean(L, 0);
    return 1;
}
    
static int setrawmetatable(lua_State* L) {
    if (lua_istable(L, 1) && lua_istable(L, 2)) {
        lua_getmetatable(L, 1);
        *(Table*)lua_topointer(L, -1) = *(Table*)lua_topointer(L, 2);
        lua_pushboolean(L, 1);
        return 1;
    }
    lua_pushboolean(L, 0);
    return 1;
}

static int wait(lua_State* L) {
    if (lua_isnumber(L, 1)) {
        Sleep(1000 * lua_tonumber(L, 1));
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int castint(lua_State* L) {
    if (lua_isnumber(L, 1)) {
        lua_pushinteger(L, lua_tointeger(L, 1));
        return 1;
    }
    return 0;
}

static int warn(lua_State* L) {
    if (lua_isstring(L, 1)) {
        SetConsoleTextAttribute(Console, 14);
        std::cout << "[!] " << lua_tostring(L, 1) << std::endl;
        SetConsoleTextAttribute(Console, 7);
    }
    else {
        CError(L, "[!] C based \"warn\" doesnt not interpret any other data type besides \"string\"");
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int Error(lua_State* L) {
    CError(L, lua_tostring(L, 1));
    return 0;
}

static int LuaWinApi(lua_State* L) {
    if (lua_isnumber(L, 1) && lua_tonumber(L, 1) == 1) {
        std::exit(0);
        return 0;
    }
    if (lua_isnumber(L, 1) && lua_tonumber(L, 1) == 2) {
        MessageBoxA(GetConsoleWindow(), lua_tostring(L, 3), lua_tostring(L, 2), lua_tointeger(L, 4));
        return 0;
    }
    if(lua_isnumber(L, 1) && lua_tonumber(L, 1) == 3){
        std::cout << lua_tostring(L, 2) << std::endl;
        return 0;
    }
    if (lua_isnumber(L, 1) && lua_tonumber(L, 1) == 4) {
        std::system("cls");
        return 0;
    }
    return 0;
}

#pragma endregion Functions

int main()
{
    std::thread CreateTick(StartTick);

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    std::cout << "Lua Output: \n\n";

    lua_pushcfunction(L, is_c_function);
    lua_setglobal(L, "is_c_function");

    lua_pushcfunction(L, setreadonly);
    lua_setglobal(L, "setreadonly");

    lua_pushcfunction(L, LuaWinApi);
    lua_setglobal(L, "LWA");

    lua_pushcfunction(L, newcclosure);
    lua_setglobal(L, "newcclosure");

    lua_pushcfunction(L, getrawmetatable);
    lua_setglobal(L, "getrawmetatable");

    lua_pushcfunction(L, setrawmetatable);
    lua_setglobal(L, "setrawmetatable");

    lua_pushcfunction(L, warn);
    lua_setglobal(L, "warn");

    lua_pushcfunction(L, hookfunction);
    lua_setglobal(L, "hookfunction");

    lua_pushcfunction(L, wait);
    lua_setglobal(L, "wait");

    lua_pushcfunction(L, loadstring);
    lua_setglobal(L, "loadstring");

    lua_pushcfunction(L, tick);
    lua_setglobal(L, "tick");

    lua_pushcfunction(L, castint);
    lua_setglobal(L, "castint");

    if (CheckLua(L, luaL_dofile(L, "LuaPreDefined.lua"))) {
        
    }
    if (CheckLua(L, luaL_dofile(L, "LuaExec.lua"))) {

    }
    std::system("pause");
    CreateTick.detach();
    lua_close(L);
    return 0;
}