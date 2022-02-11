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

#ifdef WIN32
#pragma comment(lib,"lua5.1.lib")
#endif

/* Ripped header file funcs to elevate permissions */
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
std::string ErrorMsg = "Cannot Class Security Check (Identity 1) Requires Identity 21 or [C].\n";
std::string SeriousErrorMsg = "Cannot Class Security Check (Identity -2147483648) Requires Lua Stack Permissions\n";

static int newcclosure(lua_State* L) {
    if (lua_iscfunction(L, 1)) {
        Closure* Function = (Closure*)lua_tofunction(L, 1);

        CClosure NewFunc = Function->c;
        lua_pushcclosure(L, NewFunc.f, 0);
        return 1;
    }
    if (lua_isfunction(L, 1)) {
        Closure* Function = (Closure*)lua_tofunction(L, 1);

        LClosure NewFunc = Function->l;
        lua_pushlclosure(L, NewFunc, 0);
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
                lua_pushstring(L, "cannot set a non-function value");
                lua_error(L);
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
                lua_pushstring(L, "cannot set a non-function value");
                lua_error(L);
            }
            return 1;
        }
    }
    return 0;
}
/*
static int GetRunningProcesses(lua_State*L) {
    PROCESSENTRY32 ProcessEntry;
    ProcessEntry.dwSize = sizeof(PROCESSENTRY32);
    auto Processes = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    while (Process32Next(Processes, &ProcessEntry)) {

    };
    return 0;
}
*/
static int clear(lua_State* L) {
    std::system("CLS");
    return 0;
}
static int loadstring(lua_State* L) {
    if (lua_type(L, 1) == LUA_TSTRING) {
        std::string exec = lua_tostring(L, 1);
        if (CheckLua(L, luaL_dostring(L, exec.c_str()))) {

        };
    }
    else {
        lua_pushstring(L, ErrorMsg.c_str());
        lua_error(L);
    }
    return 0;
}
static int Error(lua_State* L) {
    if (lua_type(L, 1) == LUA_TSTRING) {
        lua_error(L);
    }
    else {
        std::cout << "Error requires a string value" << "\n";
        lua_close(L);        
    }
    return 0;
}
static int wait(lua_State* L) {
    if (lua_type(L, 1) == LUA_TNUMBER) {
        DWORD Time = lua_tonumber(L, 1);
        Time = Time * 1000;
        Sleep(Time);
    }
    else {
        if (lua_type(L, 1) == LUA_TNIL) {
            Sleep(1);
        }
    }
    lua_pushboolean(L, true);
    return 1;
}
HANDLE ProcessHandle;
DWORD ProcessId;

static int attach(lua_State* L) {
    if (lua_type(L, 1) == LUA_TSTRING) {
        std::string ProcessName = lua_tostring(L, 1);
        PROCESSENTRY32 procEntry;
        procEntry.dwSize = sizeof(PROCESSENTRY32);
        auto ProcessSnapshotHandle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (ProcessSnapshotHandle == INVALID_HANDLE_VALUE) {
            std::cout << "Failed to get the running processes.";
            lua_pushnil(L);
            return 1;
        }
        while (Process32Next(ProcessSnapshotHandle, &procEntry)) {
            std::cout << ProcessName << std::endl;
            std::cout << (const char*)procEntry.szExeFile << std::endl;
            /*
            if (!strcmp(ProcessName.c_str(), (const char*)procEntry.szExeFile)) {
                
            }
            */
        }
    }
    return 1;
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

static int print(lua_State* L) {
    if (lua_isstring(L, 1)) {
        std::string str = lua_tostring(L, 1);
        std::cout << str << std::endl;
    }
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

static int setrawmetatable(lua_State* L) {
    lua_pushstring(L, "not working right yet lol");
    return 1;
}
int main()
{
    std::thread CreateTick(StartTick);

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    std::cout << "Lua Output: \n\n";

    lua_pushcfunction(L, is_c_function);
    lua_setglobal(L, "is_c_function");

    lua_pushcfunction(L, newcclosure);
    lua_setglobal(L, "newcclosure");

    lua_pushcfunction(L, setrawmetatable);
    lua_setglobal(L, "setrawmetatable");

    lua_pushcfunction(L, getrawmetatable);
    lua_setglobal(L, "getrawmetatable");

    lua_pushcfunction(L, hookfunction);
    lua_setglobal(L, "hookfunction");

    lua_pushcfunction(L, wait);
    lua_setglobal(L, "wait");

    lua_pushcfunction(L, Error);
    lua_setglobal(L, "Error");

    lua_pushcfunction(L, loadstring);
    lua_setglobal(L, "loadstring");

    lua_pushcfunction(L, clear);
    lua_setglobal(L, "ClearConsole");

    lua_pushcfunction(L, tick);
    lua_setglobal(L, "tick");

    lua_pushcfunction(L, attach);
    lua_setglobal(L, "WProcAttach");

    lua_pushnumber(L, -INFINITY);
    lua_setglobal(L, "NaN");

    if (CheckLua(L, luaL_dofile(L, "LuaPreDefined.lua"))) {
        
    }
    if (CheckLua(L, luaL_dofile(L, "LuaExec.lua"))) {
        lua_pushcfunction(L, Error);
        lua_setglobal(L, "CError");
        if (CheckLua(L, luaL_dostring(L, "if(typeof(_G)~=[[table]])then CError([[\nCannot Class Security Check (Identity 1) Requires Identity 20.]]) elseif(getmetatable(_G)~=[[_G Enviornment Protection]])then CError([[\nCannot Class Security Check (Identity 1) Requires Identity 20.]]) end"))) {

        }
    }
    std::system("pause");
    CreateTick.detach();
    lua_close(L);
    return 0;
}