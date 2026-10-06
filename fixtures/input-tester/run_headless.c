#include <mgba/internal/gb/gb.h>
#include <mgba/internal/sm83/sm83.h>
#include <mgba/core/core.h>
#include <mgba/core/config.h>
#include <mgba/core/directories.h>
#include <mgba-util/vfs.h>
#include <mgba/internal/gb/input.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define MAX_WAIT_FRAMES 300
#define SCREEN_STRIDE 256
#define SCREEN_HEIGHT 256

static unsigned char rd(struct mCore* c, unsigned addr) {
    return c->busRead8(c, addr);
}

static uint64_t screenHash(struct mCore* c, unsigned width, unsigned height) {
    const void* pixels = NULL;
    size_t stride = 0;
    c->getPixels(c, &pixels, &stride);
    if (!pixels || stride < width) return 0;
    const unsigned char* bytes = pixels;
    uint64_t hash = 1469598103934665603ULL;
    for (size_t i = 0; i < stride * height * sizeof(mColor); ++i) {
        hash ^= bytes[i];
        hash *= 1099511628211ULL;
    }
    return hash;
}

static void saveScreen(struct mCore* c, const char* path, unsigned width, unsigned height) {
    const void* pixels = NULL;
    size_t stride = 0;
    c->getPixels(c, &pixels, &stride);
    if (!pixels || stride < width) return;
    FILE* ppm = fopen(path, "wb");
    if (!ppm) return;
    fprintf(ppm, "P6\n%u %u\n255\n", width, height);
    for (unsigned y = 0; y < height; ++y) {
        for (unsigned x = 0; x < width; ++x) {
            unsigned char rgb[3];
#ifdef COLOR_16_BIT
            uint16_t pixel = ((const uint16_t*) pixels)[y * stride + x];
            rgb[0] = M_R8(pixel); rgb[1] = M_G8(pixel); rgb[2] = M_B8(pixel);
#else
            uint32_t pixel = ((const uint32_t*) pixels)[y * stride + x];
            rgb[0] = pixel & 0xFF; rgb[1] = (pixel >> 8) & 0xFF; rgb[2] = (pixel >> 16) & 0xFF;
#endif
            fwrite(rgb, 1, sizeof(rgb), ppm);
        }
    }
    fclose(ppm);
}

static int waitForChange(struct mCore* c, unsigned addr, unsigned char before) {
    for (unsigned i = 0; i < MAX_WAIT_FRAMES; ++i) {
        c->runFrame(c);
        if (rd(c, addr) != before) return 1;
    }
    return 0;
}

int main(int argc, char** argv) {
    if (argc != 3) return 2;
    struct mCore* c = mCoreFind(argv[1]);
    if (!c || !c->init(c)) return 3;
    mCoreInitConfig(c, "headless");
    if (!mCoreLoadFile(c, argv[1])) return 4;
    c->dirs.save = VDirOpen(argv[2]);
    strcpy(c->dirs.baseName, "padtest");
    if (!mCoreAutoloadSave(c)) return 5;

    mColor pixels[SCREEN_STRIDE * SCREEN_HEIGHT];
    memset(pixels, 0, sizeof(pixels));
    c->setVideoBuffer(c, pixels, SCREEN_STRIDE);
    c->reset(c);
    struct GB* gb = (struct GB*) c->board;
    for (unsigned i = 0; i < 900; ++i) c->runFrame(c);

    /* Synthetic dispatch: this does not validate natural list recognition. */
    gb->cpu->pc = 0x026D;
    gb->cpu->a = 0x10;
    c->setKeys(c, 0);
    c->runFrame(c);
    for (unsigned i = 0; i < MAX_WAIT_FRAMES && rd(c, 0xD800) == 0; ++i) c->runFrame(c);
    int initialized = rd(c, 0xD800) != 0;
    for (unsigned i = 0; i < 8; ++i) if (rd(c, 0xD803 + i) != 0) initialized = 0;
    printf("fixture init=%s frame=%u pc=%04X\n", initialized ? "PASS" : "FAIL", rd(c, 0xD800), gb->cpu->pc);
    if (!initialized) return 6;

    unsigned width = 0, height = 0;
    c->currentVideoSize(c, &width, &height);
    int pass = width == 160 && height == 144;
    uint64_t previousReleased = screenHash(c, width, height);
    const int keys[] = {GB_KEY_A, GB_KEY_B, GB_KEY_START, GB_KEY_SELECT,
                        GB_KEY_RIGHT, GB_KEY_LEFT, GB_KEY_UP, GB_KEY_DOWN};
    const char* names[] = {"A", "B", "START", "SELECT", "RIGHT", "LEFT", "UP", "DOWN"};

    for (unsigned i = 0; i < 8; ++i) {
        unsigned counterAddr = 0xD803 + keys[i];
        unsigned char oldCounter = rd(c, counterAddr);
        unsigned char oldFrame = rd(c, 0xD800);
        c->setKeys(c, 1u << keys[i]);
        unsigned wait;
        for (wait = 0; wait < MAX_WAIT_FRAMES && rd(c, counterAddr) == oldCounter; ++wait) c->runFrame(c);
        int sampled = rd(c, counterAddr) == (unsigned char)(oldCounter + 1);
        unsigned char frameAtPress = rd(c, 0xD800);
        int renderedPressed = waitForChange(c, 0xD800, frameAtPress);
        for (unsigned f = 0; f < 20; ++f) c->runFrame(c);
        unsigned char heldAtPress = rd(c, 0xD802);
        uint64_t pressedHash = screenHash(c, width, height);
        int visibleChange = pressedHash != previousReleased;
        if (i == 0) {
            char path[512]; snprintf(path, sizeof(path), "%s/screen_pressed.ppm", argv[2]);
            saveScreen(c, path, width, height);
        }

        c->setKeys(c, 0);
        unsigned releaseWait;
        for (releaseWait = 0; releaseWait < MAX_WAIT_FRAMES && rd(c, 0xD802) != 0; ++releaseWait) c->runFrame(c);
        unsigned char frameAtRelease = rd(c, 0xD800);
        int renderedReleased = waitForChange(c, 0xD800, frameAtRelease);
        for (unsigned f = 0; f < 20; ++f) c->runFrame(c);
        uint64_t releasedHash = screenHash(c, width, height);
        int releaseVisibleChange = releasedHash != pressedHash;
        printf("%-6s sampled=%s counter=%u rendered=%s/%s visible=%s/%s\n",
               names[i], sampled ? "PASS" : "FAIL", rd(c, counterAddr),
               renderedPressed ? "PASS" : "FAIL", renderedReleased ? "PASS" : "FAIL",
               visibleChange ? "PASS" : "FAIL", releaseVisibleChange ? "PASS" : "FAIL");
        printf("       held press/release=%02X/%02X screen hashes=%016llx/%016llx\n",
               heldAtPress, rd(c, 0xD802), (unsigned long long) pressedHash,
               (unsigned long long) releasedHash);
        if (!sampled || !renderedPressed || !renderedReleased || !visibleChange || !releaseVisibleChange) pass = 0;
        previousReleased = releasedHash;
    }

    unsigned char allCounts = 1;
    for (unsigned i = 0; i < 8; ++i) if (rd(c, 0xD803 + i) != 1) allCounts = 0;
    pass &= allCounts;
    for (unsigned f = 0; f < 120; ++f) c->runFrame(c);
    char finalPath[512]; snprintf(finalPath, sizeof(finalPath), "%s/screen_final.ppm", argv[2]);
    saveScreen(c, finalPath, width, height);
    printf("counts=%s framebuffer=%ux%u hash=%016llx overall=%s frame=%u pc=%04X\n",
           allCounts ? "8/8 PASS" : "FAIL", width, height,
           (unsigned long long) screenHash(c, width, height), pass ? "PASS" : "FAIL",
           c->frameCounter(c), gb->cpu->pc);
    printf("LCDC=%02X VBK=%02X BGP=%02X VRAM row0:",rd(c,0xFF40),rd(c,0xFF4F),rd(c,0xFF47)); for (unsigned i=0;i<20;i++) printf(" %02X", rd(c,0x9800+i)); printf("\nWRAM row3:"); for (unsigned i=0;i<20;i++) printf(" %02X", rd(c,0xC860+i)); printf("\nVRAM row3:"); for (unsigned i=0;i<20;i++) printf(" %02X", rd(c,0x9860+i)); printf("\nfont:"); for (unsigned i=0;i<32;i++) printf(" %02X", rd(c,0x8000+i)); printf("\n");
    printf("P tile:"); for (unsigned i=0;i<16;i++) printf(" %02X",rd(c,0x80D0+i)); printf("\nD tile:"); for (unsigned i=0;i<16;i++) printf(" %02X",rd(c,0x8040+i)); printf("\n");

    c->unloadROM(c);
    mCoreConfigDeinit(&c->config);
    c->deinit(c);
    return pass ? 0 : 8;
}
