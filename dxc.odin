package dxc

import "core:sys/win32"

HRESULT :: u32;

GUID :: struct{
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
}

foreign import dxcompiler "dxcompiler.lib"

@(default_calling_convention="std")
foreign dxcompiler {
    DxcCreateInstance :: proc(rclsid: ^GUID, riid: ^GUID, ppv: ^rawptr) -> HRESULT ---;
}

IUnknown_Vtbl :: struct {
    QueryInterface : proc "c" (this: rawptr, riid: ^GUID, ppvObject: ^rawptr) -> HRESULT,
    AddRef : proc "c" (this: rawptr) -> u32,
    Release : proc "c" (this: rawptr) -> u32,
    // Destructor : proc "c" (this: rawptr),
}

IUnknown_Poly :: struct(Vtbl: typeid) {
    using lpVtbl : ^Vtbl,
    count : u32,
}

IUnknown :: distinct IUnknown_Poly(IUnknown_Vtbl);

IDxcBlob_Vtbl :: struct {
    using _ : IUnknown_Vtbl,
    GetBufferPointer : proc "c" (this: rawptr) -> rawptr,
    GetBufferSize : proc "c" (this: rawptr) -> uint,
}

IDxcBlob :: distinct IUnknown_Poly(IDxcBlob_Vtbl);

IDxcBlobEncoding_Vtbl :: struct {
    using _ : IDxcBlob_Vtbl,
    GetEncoding : rawptr,
}

IDxcBlobEncoding :: distinct IUnknown_Poly(IDxcBlobEncoding_Vtbl);

IDxcUtils_Vtbl :: struct {
    using _ : IUnknown_Vtbl,

    CreateBlobFromBlob : rawptr,
    CreateBlobFromPinned : proc "c" (this: rawptr, pData: rawptr, size: u32, codePage: u32, pBlobEncoding: ^(^IDxcBlobEncoding)) -> HRESULT,
    MoveToBlob : rawptr,
    CreateBlob : rawptr,
    LoadFile : rawptr,
    CreateReadOnlyStreamFromBlob : rawptr,
    CreateDefaultIncludeHandle : rawptr,
    GetBlobAsUtf8 : rawptr,
    GetBlobAsUtf16 : rawptr,
    GetDxilContainerPart : rawptr,
    CreateReflection : rawptr, 
    BuildArguments : rawptr, 
    GetPDBContents : rawptr,
}

// 4605C4CB-2019-492A-ADA4-65F20BB7D67F
IDxcUtils_GUID := GUID{
    Data1 = 0x4605C4CB,
    Data2 = 0x2019,
    Data3 = 0x492a,
    Data4 = [8]u8{ 0xAD, 0xA4, 0x65, 0xF2, 0x0B, 0xB7, 0xD6, 0x7F },
};
IDxcUtils :: distinct IUnknown_Poly(IDxcUtils_Vtbl);

// 6245D6AF-66E0-48FD-80B4-4D271796748C
CLSID_DxcUtils := GUID{
    Data1 = 0x6245D6AF,
    Data2 = 0x66E0,
    Data3 = 0x48FD,
    Data4 = [8]u8{ 0x80, 0xB4, 0x4D, 0x27, 0x17, 0x96, 0x74, 0x8C },
};

DxcBuffer :: struct {
    Ptr  : rawptr,
    Size : uint,
    Encoding : u32,
}

IDxcCompiler3_Vtbl :: struct {
    using _ : IUnknown_Vtbl,
    Compile : proc "c" (this: rawptr, pSource: ^DxcBuffer, pArguments: ^win32.Wstring, argCount: u32, pIncludeHandler: rawptr /* TODO */, riid: ^GUID, ppResult: ^rawptr) -> HRESULT,
    Disassemble : rawptr,
}

// 228B4687-5A6A-4730-900C-9702B2203F54
IDxcCompiler3_GUID := GUID{
    Data1 = 0x228B4687,
    Data2 = 0x5A6A,
    Data3 = 0x4730,
    Data4 = [8]u8{ 0x90, 0x0C, 0x97, 0x02, 0xB2, 0x20, 0x3F, 0x54 },
};
IDxcCompiler3 :: distinct IUnknown_Poly(IDxcCompiler3_Vtbl);

CLSID_DxcCompiler := GUID{
    Data1 = 0x73e22d93,
    Data2 = 0xe6ce,
    Data3 = 0x47f3,
    Data4 = [8]u8{ 0xb5, 0xbf, 0xf0, 0x66, 0x4f, 0x39, 0xc1, 0xb0 },
};

CP_UTF8 :: 65001;

IDxcOperationResult_Vtbl :: struct {
    using _ : IUnknown_Vtbl,

    GetStatus : proc "c" (this: rawptr, pStatus: ^HRESULT) -> HRESULT,
    GetResult : proc "c" (this: rawptr, ppResult: ^(^IDxcBlob)) -> HRESULT,
    GetErrorBuffer : proc "c" (this: rawptr, ppErrors: ^(^IDxcBlobEncoding)) -> HRESULT,
}

DXC_OUT_KIND :: enum {
    NONE = 0,
    OBJECT = 1,         // IDxcBlob - Shader or library object
    ERRORS = 2,         // IDxcBlobUtf8 or IDxcBlobUtf16
    PDB = 3,            // IDxcBlob
    SHADER_HASH = 4,    // IDxcBlob - DxcShaderHash of shader or shader with source info (-Zsb/-Zss)
    DISASSEMBLY = 5,    // IDxcBlobUtf8 or IDxcBlobUtf16 - from Disassemble
    HLSL = 6,           // IDxcBlobUtf8 or IDxcBlobUtf16 - from Preprocessor or Rewriter
    TEXT = 7,           // IDxcBlobUtf8 or IDxcBlobUtf16 - other text, such as -ast-dump or -Odump
    REFLECTION = 8,     // IDxcBlob - RDAT part with reflection data
    ROOT_SIGNATURE = 9, // IDxcBlob - Serialized root signature output
    EXTRA_OUTPUTS  = 10,// IDxcExtraResults - Extra outputs

    FORCE_DWORD = 0xFFFFFFFF
}

IDxcResult_Vtbl :: struct {
    using _ : IDxcOperationResult_Vtbl,
    HasOutput : rawptr,
    GetOutput : rawptr,
    // TODO: Do more
}

// 58346CDA-DDE7-4497-9461-6F87AF5E0659
IDxcResult_GUID := GUID{
    Data1 = 0x58346CDA,
    Data2 = 0xDDE7,
    Data3 = 0x4497,
    Data4 = [8]u8{ 0x94, 0x61, 0x6f, 0x87, 0xaf, 0x5e, 0x06, 0x59 },
};
IDxcResult :: distinct IUnknown_Poly(IDxcResult_Vtbl);

// Custom api that does not have to be used
/*

import "core:log" // temp
import "core:mem"

API :: enum {
    Vulkan,
    DirectX12
}

Shader_Type :: enum {
    Pixel,
    Vertex,
}

State :: struct {
    utils  : ^IDxcUtils,
    compiler : ^IDxcCompiler3,
    api : API,
}

@private state : State;

init :: proc(api: API) {
    using state;

    result := DxcCreateInstance(&CLSID_DxcUtils, &IDxcUtils_GUID, auto_cast &utils);
    assert(result == 0);

    result = DxcCreateInstance(&CLSID_DxcCompiler, &IDxcCompiler3_GUID, auto_cast &compiler);
    assert(result == 0);
}

compile :: proc(source: []u8, path: string, type: Shader_Type) -> (out: []u8, ok: bool) {
    using state;

    source_blob : ^IDxcBlobEncoding;
    err := utils->CreateBlobFromPinned(&source[0], u32(len(source)), CP_UTF8, &source_blob);
    assert(err == 0);
    defer source_blob->Release();

    buffer : DxcBuffer;
    buffer.Ptr = source_blob->GetBufferPointer();
    buffer.Size = source_blob->GetBufferSize();
    buffer.Encoding = CP_UTF8;

    arguments := make([dynamic]win32.Wstring, 0, 12);
    defer delete(arguments);

    append(&arguments, win32.utf8_to_wstring("-E"));
    append(&arguments, win32.utf8_to_wstring("main"));
    append(&arguments, win32.utf8_to_wstring("-T"));
    switch type {
    case .Pixel: append(&arguments, win32.utf8_to_wstring("ps_6_6"));
    case .Vertex: append(&arguments, win32.utf8_to_wstring("vs_6_6"));
    }

    if api == .Vulkan {
        append(&arguments, win32.utf8_to_wstring("-spirv"));
    }

    result : ^IDxcResult;
    err = compiler->Compile(&buffer, &arguments[0], u32(len(arguments)), nil, &IDxcResult_GUID, auto_cast &result);
    assert(err == 0);
    defer result->Release();

    errors : ^IDxcBlobEncoding;
    err = result->GetErrorBuffer(&errors);
    assert(err == 0);
    if errors != nil {
        defer errors->Release();

        error := cast(cstring)errors->GetBufferPointer();
        log.error("[DXC] Compilation Error\n", error);

        ok = false;
        return;
    }
    
    ok = true;

    out_blob : ^IDxcBlob;
    err = result->GetResult(&out_blob);
    assert(err == 0);
    defer out_blob->Release();

    out_len := int(out_blob->GetBufferSize());
    out = make([]u8, out_len);
    mem.copy(&out[0], out_blob->GetBufferPointer(), out_len);

    return;
}
*/