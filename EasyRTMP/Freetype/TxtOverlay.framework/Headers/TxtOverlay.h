//
//  TxtOverlay.hpp
//  EasyRTMP
//
//  Created by leo on 2020/7/21.
//  Copyright © 2020 phylony. All rights reserved.
//

#ifndef TxtOverlay_hpp
#define TxtOverlay_hpp

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

long txtOverlayInit(int w, int h, const char* fonts, int size);
void txtOverlay(long ctx, unsigned char* buffer, wchar_t* txt, size_t len, int x, int y);
void txtOverlayRelease(long ctx);

#ifdef __cplusplus
}
#endif

#endif /* TxtOverlay_hpp */
