//
//  MinecraftBiomeImageGeneratorTests.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 12-07-2025.
//

import CryptoKit
import Foundation
import Testing

@testable import CubiomesKit

struct MinecraftBiomeImageGeneratorTests {
    @Test func imageGeneratorMatchesUtils() throws {
        let world = MinecraftWorld(version: MC_NEWEST, seed: 123456)
        var generator = world.generator(in: .nether)
        let rect = MinecraftWorldRect(origin: .zero, scale: MinecraftWorldRect.Size(squaring: 4))

        let cbRange = Cubiomes.Range(
            scale: 4,
            x: rect.origin.x,
            z: rect.origin.z,
            sx: rect.size.length,
            sz: rect.size.width,
            y: rect.origin.y,
            sy: rect.size.height
        )

        let biomeIDs = allocCache(&generator, cbRange)
        genBiomes(&generator, biomeIDs, cbRange)

        var colorGroup: (UInt8, UInt8, UInt8) = (0, 0, 0)
        initBiomeColors(&colorGroup)

        let imgWidth = rect.size.length
        let imgHeight = rect.size.width

        var expectedData = [CUnsignedChar](repeating: 0, count: Int(3 * imgWidth * imgHeight))
        biomesToImage(
            &expectedData,
            &colorGroup,
            UnsafePointer(
                biomeIDs
            ),
            UInt32(rect.size.length),
            UInt32(rect.size.height),
            1,
            2
        )

        var actualData = [CUnsignedChar](repeating: 0, count: Int(3 * imgWidth * imgHeight))
        applesauce(
            data: &actualData,
            colors: &colorGroup,
            biomeIDs: UnsafePointer(biomeIDs),
            width: UInt32(rect.size.length),
            height: UInt32(rect.size.height),
            pixelsPerCell: 1,
            flip: true
        )

        print(expectedData)

        let expectedHash = SHA256.hash(data: expectedData)
        let actualHash = SHA256.hash(data: actualData)

        #expect(expectedHash == actualHash)
    }

    @discardableResult
    func applesauce(
        data: inout [CUnsignedChar],
        colors: UnsafeMutablePointer<(UInt8, UInt8, UInt8)>!,
        biomeIDs: UnsafePointer<Int32>!,
        width: UInt32,
        height: UInt32,
        pixelsPerCell: UInt32,
        flip: Bool
    ) -> Bool {
//        int biomesToImage(
//                unsigned char *pixels, <-- data
//                unsigned char biomeColors[256][3], <-- colors
//                const int *biomes, <-- biomeIDs
//                const unsigned int sx, <-- width
//                const unsigned int sy, <-- height
//                const unsigned int pixscale, <-- pixelsPerCell
//                const int flip <-- flip
//        ) {
//            unsigned int i, j;
//            int containsInvalidBiomes = 0;

        var containsInvalidBiomes = false

//            for (j = 0; j < sy; j++)
//            {
//                for (i = 0; i < sx; i++)
//                {
        for j in 0 ..< Int(height) {
            for i in 0 ..< Int(width) {
//                    int id = biomes[j*sx+i];
//                    unsigned int r, g, b;

                let biomeID = biomeIDs[j * Int(width) + i]
                var (r, g, b): (UInt8, UInt8, UInt8) = (0, 0, 0)

//
//                    if (id < 0 || id >= 256)
//                    {
                if (0...256).contains(biomeID) {
                    (r, g, b) = colors[Int(biomeID)]
//                        r = biomeColors[id][0];
//                        g = biomeColors[id][1];
//                        b = biomeColors[id][2];
                } else {
                    // This may happen for some intermediate layers
                    containsInvalidBiomes = true
                    (r, g, b) = colors[Int(biomeID & 0x7f)]
                    r -= 40
                    g -= 40
                    b -= 40

                    r = r > 255 ? 0 : r & 255
                    g = g > 255 ? 0 : g & 255
                    b = b > 255 ? 0 : b & 255
//                        containsInvalidBiomes = 1;
//                        r = biomeColors[id&0x7f][0]-40; r = (r>0xff) ? 0x00 : r&0xff;
//                        g = biomeColors[id&0x7f][1]-40; g = (g>0xff) ? 0x00 : g&0xff;
//                        b = biomeColors[id&0x7f][2]-40; b = (b>0xff) ? 0x00 : b&0xff;
                }
//                    }
//
//                    unsigned int m, n;
//                    for (m = 0; m < pixscale; m++) {
//                        for (n = 0; n < pixscale; n++) {
                for m in 0 ..< pixelsPerCell {
                    for n in 0 ..< pixelsPerCell {
                        var idx = pixelsPerCell * UInt32(i) + n
                        if flip {
                            idx += (width * pixelsPerCell) * ((pixelsPerCell * UInt32(j)) + m)
                        } else {
                            idx += (width * pixelsPerCell) * ((pixelsPerCell * (height - 1 - UInt32(j))) + m)
                        }
//                            int idx = pixscale * i + n;
//                            if (flip)
//                                idx += (sx * pixscale) * ((pixscale * j) + m);
//                            else
//                                idx += (sx * pixscale) * ((pixscale * (sy-1-j)) + m);

                        data[(3 * Int(idx))] = r
                        data[(3 * Int(idx)) + 1] = g
                        data[(3 * Int(idx)) + 2] = b
                        
//                            unsigned char *pix = pixels + 3*idx;
//                            pix[0] = (unsigned char)r;
//                            pix[1] = (unsigned char)g;
//                            pix[2] = (unsigned char)b;
                    }
                }
//                        }
//                    }
//                }
//            }
//
//            return containsInvalidBiomes;
//        }
            }
        }
        return containsInvalidBiomes
    }
}
