#include <iostream>
#include <fstream>
#include <string>
#include <cstdint>
#include <map>
#include <cassert>
#include <zlib.h>
#include <sys/stat.h>
//#include <ShlObj.h>

std::string dataPath = "D:\\Games\\steamapps\\common\\FINAL FANTASY XIII\\white_data\\";

#pragma pack(push, 1)
struct PackInfo
{
    uint32_t uncompressedSize;
    uint32_t compressedSize;
    uint8_t* pPackData;
};

struct FileListEntry
{
    uint16_t unknown[2];
    uint16_t packNum;
    uint16_t infoOffset;
};

struct FileListInfo
{
    PackInfo *pPackInfo;
    uint8_t *pStartOfPackData;
    uint32_t nFiles;
    FileListEntry fileEntries[0];
};
#pragma pack(pop)

void Extract(const std::string &fileListName, const std::string &fileDataName, const std::string &outputDirName)
{
    std::fstream fileListFile(dataPath + fileListName, std::ios_base::in | std::ios_base::binary);
    fileListFile.seekg(0, std::ios_base::end);
    size_t fileListSize = fileListFile.tellg();
    fileListFile.seekg(0);
    char* fileListBuf = new char[fileListSize];
    fileListFile.read(fileListBuf, fileListSize);
    fileListFile.close();

    std::fstream fileDataFile(dataPath + fileDataName, std::ios_base::in | std::ios_base::binary);

    FileListInfo *fileInfo = (FileListInfo*)fileListBuf;
    *(uint32_t*)(&fileInfo->pPackInfo) += uintptr_t(fileInfo);
    *(uint32_t*)(&fileInfo->pStartOfPackData) += uintptr_t(fileInfo);

    std::map<uint16_t, char*> packData;
    for(unsigned int i = 0; i < fileInfo->nFiles; ++i)
    {
        uint16_t packNum = fileInfo->fileEntries[i].packNum;
        if(packData.find(packNum) == packData.end())
        {
            std::cout << "Processing pack " << packNum << "..." << std::endl;
            auto &packInfo = fileInfo->pPackInfo[packNum];
            *(uint32_t*)(&packInfo.pPackData) += uintptr_t(fileInfo->pStartOfPackData);
            z_stream strm;
            strm.zalloc = Z_NULL;
            strm.zfree = Z_NULL;
            strm.opaque = Z_NULL;
            inflateInit(&strm);
            strm.avail_in = packInfo.compressedSize;
            strm.avail_out = packInfo.uncompressedSize;
            strm.next_in = packInfo.pPackData;

            packData[packNum] = new char[packInfo.uncompressedSize];
            strm.next_out = (uint8_t*)packData[packNum];
            inflate(&strm, 1);
            assert(strm.avail_out == 0);
            inflateEnd(&strm);
        }
        std::string fileDesc(&packData[packNum][fileInfo->fileEntries[i].infoOffset]);
        size_t descOff = fileDesc.find(":");
        size_t off = strtol(fileDesc.substr(0, descOff).c_str(), nullptr, 16)*0x800;
        fileDesc = fileDesc.substr(descOff+1, fileDesc.length());

        descOff = fileDesc.find(":");
        size_t size = strtol(fileDesc.substr(0, descOff).c_str(), nullptr, 16);
        fileDesc = fileDesc.substr(descOff+1, fileDesc.length());

        descOff = fileDesc.find(":");
        size_t compressedSize = strtol(fileDesc.substr(0, descOff).c_str(), nullptr, 16);
        fileDesc = fileDesc.substr(descOff+1, fileDesc.length());

        fileDataFile.seekg(off);
        char* cbuf = new char[compressedSize];
        char* ubuf = new char[size];

        if(compressedSize != size)
        {
            fileDataFile.read(cbuf, compressedSize);

            z_stream strm;
            strm.zalloc = Z_NULL;
            strm.zfree = Z_NULL;
            strm.opaque = Z_NULL;
            inflateInit(&strm);
            strm.avail_in = compressedSize;
            strm.avail_out = size;
            strm.next_in = (uint8_t*)cbuf;
            strm.next_out = (uint8_t*)ubuf;
            inflate(&strm, 1);
            assert(strm.avail_out == 0);
            inflateEnd(&strm);
        }
        else
        {
            fileDataFile.read(ubuf, size);
        }

        delete [] cbuf;

        std::string filePath = dataPath + outputDirName + fileDesc;
        size_t slashOff = -1;
        descOff = filePath.find("/");
        while(descOff != std::string::npos)
        {
            slashOff = descOff;
            descOff = filePath.find("/", descOff+1);
        }

        std::string fileName = filePath.substr(slashOff + 1, filePath.length());
        filePath = filePath.substr(0, slashOff+1);
        for(size_t i = 0; i < filePath.length(); ++i)
        {
            if(filePath[i] == '/')
            {
                filePath[i] = '\\';
            }
        }

        //SHCreateDirectoryExA(NULL, filePath.c_str(), nullptr);
        mkdir(filePath.c_str(), 0777);

        std::fstream outFile(filePath + fileName, std::ios_base::out | std::ios_base::binary);
        outFile.write(ubuf, size);
        outFile.close();

        delete [] ubuf;
    }
}

int main(int argc, char *argv[])
{
    Extract("sys/filelist_scru.win32.bin", "sys/white_scru.win32.bin", "");
}