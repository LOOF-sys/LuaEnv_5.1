#include <iostream>
#include <windows.h>
#include <TlHelp32.h>
#include <string>
#include <thread>

extern "C" {
#include "include/lauxlib.h"
#include "include/lua.h"
#include "include/lualib.h"
#include "include/lobject.h"
}

#ifdef WIN32
#pragma comment(lib,"lua5.1.lib")
#endif

void* lua_tofunction(lua_State* L, int stackn) {
    return (void*)lua_topointer(L, stackn);
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

static int hook(lua_State* L) {
    if (lua_type(L, 3) == LUA_TSTRING) {
        std::string main_check = lua_tostring(L, 3);
        if (main_check != "C") {
            lua_pushstring(L, ErrorMsg.c_str());
            lua_error(L);
        }
    }
    else {
        lua_pushstring(L, ErrorMsg.c_str());
        lua_error(L);
    }
    if (lua_isfunction(L,1)) {
        if (lua_isfunction(L, 2)) {
            void* FirstFunc = lua_tofunction(L,1);
            void* TempPtr = lua_tofunction(L, 2);

            if (FirstFunc && TempPtr != 0 || NULL) {
                
            }
            else {
                std::cout << "hookfunction failure\n";
            }
        }
        else {
            if (lua_isnil(L, 2)) {
                std::string Lwrite = lua_tostring(L, 1);
                if (Lwrite == "Error") {
                    std::cout << ErrorMsg;
                }
                else {
                    lua_getglobal(L, Lwrite.c_str());
                    lua_pushnil(L);
                    lua_setglobal(L, Lwrite.c_str());
                }
            }
        }
    }
    else
    {
        if (lua_type(L, 1) == LUA_TBOOLEAN) {
            if (lua_tostring(L, 2)) {
                std::string Lwrite = lua_tostring(L, 2);
                lua_getglobal(L, Lwrite.c_str());
                lua_pushnil(L);
                lua_setglobal(L, Lwrite.c_str());
            }
        }
        else {
            if (lua_type(L, 1) == LUA_TTABLE) {
                if (lua_tostring(L, 2)) {
                    std::string Lwrite = lua_tostring(L, 2);
                    if (Lwrite == "_G" || Lwrite == "_ENV") {
                        std::cout << ErrorMsg;
                    }
                    else {
                        lua_getglobal(L, Lwrite.c_str());
                        lua_pushnil(L);
                        lua_setglobal(L, Lwrite.c_str());
                    }
                }
            }
            else {
                if (lua_type(L, 1) == LUA_TSTRING) {
                    if (lua_tostring(L, 2)) {
                        std::string Lwrite = lua_tostring(L, 2);
                        lua_getglobal(L, Lwrite.c_str());
                        lua_pushnil(L);
                        lua_setglobal(L, Lwrite.c_str());
                    }
                }
            }
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
/* function hooks */
std::string hook_string;
int hook_int;
static int LUA_HOOK(lua_State* L) {
    if (lua_type(L, 1) != LUA_TNIL) {
        if (lua_isstring(L, 1)) {
            hook_string = lua_tostring(L, 1);
            lua_pushstring(L, hook_string.c_str());
        }
        else {
            if (lua_isnumber(L, 1)) {
                hook_int = lua_tonumber(L, 1);
                lua_pushnumber(L, hook_int);
            }
        }
    }
    else {
        lua_pushnil(L);
    }
    return 1;
}
/* =============== */
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
    return 0;
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

int main()
{
    std::thread CreateTick(StartTick);

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    std::cout << "Lua Output: \n\n";

    lua_pushcfunction(L, hook);
    lua_setglobal(L, "hook");

    lua_pushcfunction(L, wait);
    lua_setglobal(L, "wait");

    lua_pushcfunction(L, Error);
    lua_setglobal(L, "Error");

    lua_pushcfunction(L, loadstring);
    lua_setglobal(L, "loadstring");

    lua_pushcfunction(L, clear);
    lua_setglobal(L, "ClearConsole");

    lua_pushcfunction(L, LUA_HOOK);
    lua_setglobal(L, "LUA_HOOK");

    lua_pushcfunction(L, tick);
    lua_setglobal(L, "tick");

    lua_pushcfunction(L, attach);
    lua_setglobal(L, "WProcAttach");

    if (CheckLua(L, luaL_dofile(L, "LuaPreDefined.lua"))) {

    }
    if (CheckLua(L, luaL_dofile(L, "LuaExec.lua"))) {
        lua_pushcfunction(L, Error);
        lua_setglobal(L, "CError");
        if (CheckLua(L, luaL_dostring(L, "if(typeof(_G)~=[[table]])then CError([[\nCannot Class Security Check (Identity 1) Requires Identity 20.]]) elseif(getmetatable(_G)~=[[_G Enviornment Protection]])then CError([[\nCannot Class Security Check (Identity 1) Requires Identity 20.]]) end"))) {

        }
    }
    std::system("pause");
    lua_close(L);
    CreateTick.detach();
    return 0;
}