//
//  File.metal
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/15.
//  Copyright © 2018 Jake. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    //MARK: LUT
    float4 commitLUT(sampler image, sampler lut, float intensity) {
        float4 textureColor = image.sample(image.coord());
        textureColor = clamp(textureColor, float4(0.0), float4(1.0));
        
        float blueColor = textureColor.b * 63.0;
        
        float2 quad1;
        quad1.y = floor(floor(blueColor) / 8.0);
        quad1.x = floor(blueColor) - (quad1.y * 8.0);
        
        float2 quad2;
        quad2.y = floor(ceil(blueColor) / 8.0);
        quad2.x = ceil(blueColor) - (quad2.y * 8.0);
        
        float2 texPos1;
        texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
        texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
        
        float2 texPos2;
        texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
        texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
        
        texPos1.y = 1.0 - texPos1.y;
        texPos2.y = 1.0 - texPos2.y;
        
        float4 lutExtent = lut.extent();
        
        float4 newColor1 = lut.sample(lut.transform(texPos1 * float2(512.0) + lutExtent.xy));
        float4 newColor2 = lut.sample(lut.transform(texPos2 * float2(512.0) + lutExtent.xy));
        
        float4 newColor = mix(newColor1, newColor2, fract(blueColor));
        
        return mix(textureColor, float4(newColor.rgb, textureColor.a), intensity);
    }
    
    //MARK: Opacity
    float4 commitOpacity(sample_t image, float opacity, destination dest) {
        image.a = opacity;
        
        return image.rgba;
    }
    
    //MARK: AdvancedMonochrome
    float4 advancedMonochrome(sample_t image, float redBalance, float greenBalance, float blueBalance, float _clamp) {
        float scale = 1.0 / (redBalance + greenBalance + blueBalance);
        
        float red = image.r * redBalance * scale;
        float green = image.g * greenBalance * scale;
        float blue = image.b * blueBalance * scale;
        
        float3 grey = float3(red + green + blue);
        grey = mix(grey, smoothstep(0.0, 1.0, grey), _clamp);
        
        return float4(grey, image.a);
    }
    
    //MARK: RGB Channel Compositing
    float4 rgbChannelCompositing(sample_t red, sample_t green, sample_t blue) {
        return float4(red.r, green.g, blue.b, 1.0);
    }
    
    //MARK: Bleach Bypass
    float4 bleachBypass(sample_t image, float amount) {
        float luma = dot(image.rgb, float3(0.2126, 0.7152, 0.0722));
        
        float l = min(1.0, max(0.0, 10.0 * (luma - 0.45)));
        
        float3 result1 = float3(2.0) * image.rgb * float3(luma);
        float3 result2 = 1.0 - 2.0 * (1.0 - luma) * (1.0 - image.rgb);
        float3 newColor = mix(result1, result2, l);
        
        return mix(image, float4(newColor.r, newColor.g, newColor.b, image.a), amount);
    }
    
    //MARK: Carnival Mirror
    float2 carnivalMirror(float xWavelength, float xAmount, float yWavelength, float yAmount, destination dest) {
        float2 destCoord = dest.coord();
        float y = destCoord.y + sin(destCoord.y / yWavelength) * yAmount;
        float x = destCoord.x + sin(destCoord.x / xWavelength) * xAmount;
        
        return float2(x, y);
    }
    
    //MARK: Caustic Refraction
    float4 causticNoise(float time, float tileSize, destination dest) {
        float2 uv = dest.coord() / tileSize;
        float2 p = uv - 250.0;
        float2 i = float2(p);
        
        float c = 1.0;
        float inten = 0.005;
        
        for(int n = 0; n < 5; n++) {
            float t = time * (1.0 - (3.5 /  float(n + 1)));
            i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
            c += 1.0 / length(float2(p.x / (sin(i.x + t) / inten), p.y / (cos(i.y + t) / inten)));
        }
        c /= 5.0;
        c = 1.17 - pow(c, 1.4);
        float3 color = float3(pow(abs(c), 8.0));
        color = clamp(color, 0.0, 1.0);
        return float4(color, 1.0);
    }
    
    float lumaAtOffset(sampler source, float2 origin, float2 offset) {
        float3 pixel = source.sample(source.transform(origin + offset)).rgb;
        float luma = dot(pixel, float3(0.2126, 0.7152, 0.0722));
        return luma;
    }
    
    float4 causticRefraction(sampler image, sampler refractingImage, float refractiveIndex, float lensScale, float lightingAmount, destination dest) {
        float2 d = dest.coord();
        
        float northLuma = lumaAtOffset(refractingImage, d, float2(0.0, -1.0));
        float southLuma = lumaAtOffset(refractingImage, d, float2(0.0, 1.0));
        float westLuma = lumaAtOffset(refractingImage, d, float2(-1.0, 0.0));
        float eastLuma = lumaAtOffset(refractingImage, d, float2(1.0, 0.0));
        
        float3 lensNormal = normalize(float3((eastLuma - westLuma), (southLuma - northLuma), 1.0));
        
        float3 refractVector = refract(float3(0.0, 0.0, 1.0), lensNormal, refractiveIndex) * lensScale;
        
        float3 outputPixel = image.sample(image.transform(d + refractVector.xy)).rgb;
        
        outputPixel += (northLuma - southLuma) * lightingAmount;
        outputPixel += (eastLuma - westLuma) * lightingAmount;
        
        return float4(outputPixel, 1.0);
    }
    
    
    //MARK: Kuwahara
    float4 kuwahara(sampler image, float r, destination dest) {
        float2 d = dest.coord();
        
        int radius = int(r);
        float n = float((radius + 1) * (radius + 1));
        
        float3 means[4];
        float3 stdDevs[4];
        
        for (int i = 0; i < 4; i++ ) {
            means[i] = float3(0.0);
            stdDevs[i] = float3(0.0);
        }
        
        for (int x = -radius; x <= radius; x++ ) {
            for (int y = -radius; y <= radius; y++ ){
                float3 color = image.sample(image.transform(d + float2(x, y))).rgb;
                
                float3 colorA = float3(float( x <= 0 && y <= 0)) * color;
                means[0] += colorA;
                stdDevs[0] += colorA * colorA;
                
                float3 colorB = float3(float(x >= 0 && y <= 0)) * color;
                means[1] +=  colorB;
                stdDevs[1] += colorB * colorB;
                
                float3 colorC = float3(float(x <= 0 && y >= 0)) * color;
                means[2] += colorC;
                stdDevs[2] += colorC * colorC;
                
                float3 colorD = float3(float(x >= 0 && y >= 0)) * color;
                means[3] += colorD;
                stdDevs[3] += colorD * colorD;
            }
        }
        
        float minSigma2 = 1e+2;
        float3 returnColor = float3(0.0);
        
        for (int j = 0; j < 4; j++) {
            means[j] /= n;
            stdDevs[j] = abs(stdDevs[j] / n - means[j] * means[j]);
            float sigma2 = stdDevs[j].r + stdDevs[j].g + stdDevs[j].b;
            returnColor = (sigma2 < minSigma2) ? means[j] : returnColor;
            minSigma2 = (sigma2 < minSigma2) ? sigma2 : minSigma2;
        }
        
        return float4(returnColor, 1.0);
    }
    
    //MARK: Transverse Chromatic Aberration
    float4 transverseChromaticAberration(sampler image, float2 size, float sampleCount, float start, float blur, destination dest) {
        int sampleCountInt = int(floor(sampleCount));
        float4 accumulator = float4(0.0);
        float2 dc = dest.coord();
        float normalisedValue = length(((dc / size) - 0.5) * 2.0);
        float strength = clamp((normalisedValue - start) * (1.0 / (1.0 - start)), 0.0, 1.0);
        
        float2 vector = normalize((dc - (size / 2.0)) / size);
        float2 velocity = vector * strength * blur;
        
        float2 redOffset = -vector * strength * (blur * 1.0);
        float2 greenOffset = -vector * strength * (blur * 1.5);
        float2 blueOffset = -vector * strength * (blur * 2.0);
        
        for (int i=0; i < sampleCountInt; i++) {
            accumulator.r += image.sample(image.transform(dc + redOffset)).r;
            redOffset -= velocity / sampleCount;
            
            accumulator.g += image.sample(image.transform(dc + greenOffset)).g;
            greenOffset -= velocity / sampleCount;
            
            accumulator.b += image.sample(image.transform(dc + blueOffset)).b;
            blueOffset -= velocity / sampleCount;
        }
        return float4(float3(accumulator / float(sampleCountInt)), 1.0);
    }
    
    //MARK: Scatter
    float4 scatter(sampler image, sampler noise, float radius, destination dest){
        float2 workingSpaceCoord = dest.coord() + -radius + noise.sample(noise.coord()).xy * radius * 2.0;
        float2 imageSpaceCoord = image.transform(workingSpaceCoord);
        return sample(image, imageSpaceCoord);
    }
    
    //MARK: Smooth Threshold
    float4 smoothThreshold(sample_t pixel, float inputEdgeO, float inputEdge1) {
        float luma = dot(pixel.rgb, float3(0.2126, 0.7152, 0.0722));
        float threshold = smoothstep(inputEdgeO, inputEdge1, luma);
        return float4(threshold, threshold, threshold, 1.0);
    }
    
    //MARK: Threshold
    float4 thresholdFilter(sample_t image, float threshold) {
       float luma = dot(image.rgb, float3(0.2126, 0.7152, 0.0722));
    
       return float4(step(threshold, luma));
    }
    
    //MARK: VHSTrackingLines
    float4 VHSTrackingLines(sample_t image, sample_t noise, float time, float spacing, float stripeHeight, float backgroundNoise, destination dest) {
        float2 uv = dest.coord();
        float stripe = smoothstep(1.0 - stripeHeight, 1.0, sin((time + uv.y) / spacing));
        return image + (noise * noise * stripe) + (noise * backgroundNoise);
    }
    
    //MARK: CRT
    float4 crtColor(sampler image, float pixelWidth, float pixelHeight, destination dest ) {
        int columnIndex = int(fmod(image.coord().x / pixelWidth, 3.0));
        int rowIndex = int(fmod(image.coord().y, pixelHeight));
    
        float scanlineMultiplier = (rowIndex == 0 || rowIndex == 1) ? 0.3 : 1.0;
        
        float4 color = image.sample(image.coord());
        
        float red = (columnIndex == 0) ? color.r : color.r * ((columnIndex == 2) ? 0.3 : 0.2);
        float green = (columnIndex == 1) ? color.g : color.g * ((columnIndex == 2) ? 0.3 : 0.2);
        float blue = (columnIndex == 2) ? color.b : color.b * 0.2;
    
        return float4(red * scanlineMultiplier, green * scanlineMultiplier, blue * scanlineMultiplier, 1.0);
    }
    
    float2 crtWarp(float2 extent, float bend, destination dest) {
        float2 coord = ((dest.coord() / extent) - 0.5) * 2.0;
        
        coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);
        coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);
        
        coord  = ((coord / 2.0) + 0.5) * extent;
        
        return coord;
    }
    
    //MARK: Lens Flare. Base on https://www.shadertoy.com/view/Xlc3D2
    float rnd(float w){
        float f = fract(sin(w)*1000.);
        return f;
    }
    
    float regShape(float2 p, int N){
        float f;
        float a = atan2(p.x, p.y) + .2;
        float b = 6.28319/ float(N);
        f = smoothstep(.5,.51, cos(floor(.5 + a/b) * b - a) * length(p.xy));
        
        return f;
    }
    
    float3 circle(float2 p, float size, float decay, float3 color,float3 color2, float dist, float2 mouse){
        //l is used for making rings.I get the length and pass it through a sinwave
        //but I also use a pow function. pow function + sin function , from 0 and up, = a pulse, at least
        //if you return the max of that and 0.0.
        
        float l = length(p + mouse*(dist*4.))+size/2.;
        
        ///these are circles, big, rings, and  tiny respectively
        float c = max(00.01 - pow(length(p + mouse*dist), size * 1.4), 0.0) * 50.;
        float c1 = max(0.001 - pow(l - 0.3, 1./ 40.) + sin( l * 30.), 0.0) * 3.;
        float c2 =  max(0.04 / pow(length(p- mouse * dist / 2. + 0.09) * 1., 1.), 0.0) / 20.;
        float s = max(00.01 - pow(regShape(p * 5. + mouse * dist * 5. + 0.9, 6) , 1.), 0.0) * 5.;
        
        color = 0.5 + 0.5 * sin(color);
        color = cos(float3(0.44, .24, .2) * 8. + dist * 4.) * 0.5 + .5;
        float3 f = c*color ;
        f += c1 * color;
        
        f += c2 * color;
        f +=  s * color;
        return f - 0.01;
    }
    
    float4 lensFlare(float2 inputSize, float2 inputCenter, float inputTime, destination dest ){
        float2 fragCoord = dest.coord();
        float2 uv = fragCoord.xy / inputSize.xy - 0.5;
        uv.x *= inputSize.x / inputSize.y;
        
        float2 mm = inputCenter.xy / inputSize.xy - 0.5;
        mm.x *= inputSize.x / inputSize.y;
        
        float3 circColor = float3(0.9, 0.2, 0.1);
        float3 circColor2 = float3(0.3, 0.1, 0.9);
        
        //now to make the sky not black
        float3 color = mix(float3(0.3, 0.2, 0.02)/0.9, float3(0.2, 0.5, 0.8), uv.y) * 3.0 - 0.52 * -inputTime;//sin(iTime);
        
        //this calls the function which adds three circle types every time through the loop based on parameters I
        //got by trying things out. rnd i*2000. and rnd i*20 are just to help randomize things more
        for(float i = 0.; i<10. ; i++){
            color += circle(uv, pow(rnd(i * 2000.) * 1.8, 2.)+1.41, 0.0, circColor + i , circColor2 + i, rnd(i * 20.) * 3.+ 0.2 - .5, mm);
        }
        //get angle and length of the sun (uv - mouse)
        float a = atan2(uv.y-mm.y, uv.x-mm.x);
//        float l = max(1.0-length(uv-mm)-0.84, 0.0);
        
        float bright = 0.1;//+0.1/abs(sin(iTime/3.))/3.;//add brightness based on how the sun moves so that it is brightest
        //when it is lined up with the center
        
        //add the sun with the frill things
        color += max(0.1/pow(length(uv - mm) * 5., 5.), 0.0)*abs(sin(a * 5. + cos(a * 9.))) / 20.;
        color += max(0.1/pow(length(uv - mm) * 10., 1. / 20.), .0)+abs(sin(a * 3.+ cos(a * 9.))) / 8. * (abs(sin(a * 9.)))/1.;
        //add another sun in the middle (to make it brighter)  with the20color I want, and bright as the numerator.
        color += (max(bright/pow(length(uv-mm) * 4., 1. / 2.), 0.0)* 4.) * float3(0.2, 0.21, 0.3) * 4.;
        // * (0.5+.5*sin(vec3(0.4, 0.2, 0.1) + vec3(a*2., 00., a*3.)+1.3));
        
        //multiply by the exponetial e^x ? of 1.0-length which kind of masks the brightness more so that
        //there is a sharper roll of of the light decay from the sun.
        color*= exp(1.0-length(uv-mm))/5.;
        return float4(color,1.0);
    }
    
    //MARK: Cross Zoom Transition
    float linearEase(float begin, float change, float duration, float time) {
        return change * time / duration + begin;
    }
    
    float exponentialEaseInOut(float begin, float change, float duration, float time) {
        if (time == 0.0) {
            return begin;
        } else if (time == duration) {
            return begin + change;
        }
        time = time / (duration / 2.0);
        if (time < 1.0) {
            return change / 2.0 * pow(2.0, 10.0 * (time - 1.0)) + begin;
        } else {
            return change / 2.0 * (-pow(2.0, -10.0 * (time - 1.0)) + 2.0) + begin;
        }
    }
    
    float sinusoidalEaseInOut(float begin, float change, float duration, float time) {
        float PI = 3.141592653589793;
        return -change / 2.0 * (cos(PI * time / duration) - 1.0) + begin;
    }
    
    /* random number between 0 and 1 */
    float random(float3 scale, float seed, float4 frag) {
        /* use the fragment position for randomness */
        return fract(sin(dot(frag.xyz + seed, scale)) * 43758.5453 + seed);
    }
    
    float4 crossZoomTransition(sampler inputImage, sampler inputTargetImage, float inputStrength, float4 inputExtent, float progress, destination dest) {
        // Linear interpolate center across center half of the image
        float2 center = float2(linearEase(0.25, 0.5, 1.0, progress), 0.5);
        float dissolve = exponentialEaseInOut(0.0, 1.0, 1.0, progress);
        
        // Mirrored sinusoidal loop. 0->strength then strength->0
        float strength = sinusoidalEaseInOut(0.0, inputStrength, 0.5, progress);
        
        float4 color = float4(0.0);
        float total = 0.0;
        float2 textureCoordinate = ((dest.coord() - inputExtent.xy)/inputExtent.zw);
        float2 toCenter = center - textureCoordinate;
        
        /* randomize the lookup values to hide the fixed number of samples */
        float offset = random(float3(12.9898, 78.233, 151.7182), 0.0, inputExtent);
        
        for (float t = 0.0; t <= 10.0; t++) {
            float percent = (t + offset) / 10.0;
            float weight = 4.0 * (percent - percent * percent);
            
            float2 uv = (textureCoordinate + toCenter * percent * strength) * inputExtent.zw + inputExtent.xy;
            float4 crossFade = mix(inputImage.sample(inputImage.transform(uv)), inputTargetImage.sample(inputTargetImage.transform(uv)), dissolve);
            color += crossFade * weight;
            total += weight;
        }
        return color/total;
    }
    
    //MARK: Mask
    ///Bool type is not available.
    float4 maskForCircle(sample_t inputImage, float2 inputCenter, float inputRadius, float invert, destination dest) {
        float4 textureColor = inputImage.rgba;
        float4 maskColor = float4(0.0);
        if (invert > 0) {
            maskColor = textureColor;
            textureColor = float4(0.0);
        }
        float2 location = dest.coord();
        float d = distance(inputCenter, location);
        if (d < inputRadius) {
            return textureColor;
        }
        return maskColor;
    }
    
    float4 maskForRect(sample_t inputImage, float2 inputCenter, float inputAngle, float2 inputSize, float invert, destination dest) {
        float2 location = dest.coord();
        float4 textureColor = inputImage.rgba;
        float4 maskColor = float4(0);
        if (invert > 0) {
            maskColor = textureColor;
            textureColor = float4(0);
        }

        float minX = inputCenter.x - (inputSize.x / 2);
        float maxX = inputCenter.x + (inputSize.x / 2);
        float minY = inputCenter.y - (inputSize.y / 2);
        float maxY = inputCenter.y + (inputSize.y / 2);
        
        //rotate point instead of rotate the rect
        float d = distance(inputCenter, location);
        float y = (location.y - inputCenter.y);
        float angle = asin(y / d);
        float resultAngle = angle - inputAngle;
        if (inputCenter.x < location.x) {
            resultAngle = angle + inputAngle;
        }
        float resultY = sin(resultAngle) * d + inputCenter.y;
        float resultX = cos(resultAngle) * d + inputCenter.x;

        if (resultX < minX || resultX > maxX) {
            return maskColor;
        }

        if (resultY < minY || resultY > maxY) {
            return maskColor;
        }

        return textureColor;
    }

    float4 maskForLinear(sample_t inputImage, float2 inputCenter, float inputAngle, float invert, float pi, destination dest) {
        float2 location = dest.coord();
        float4 textureColor = inputImage.rgba;
        float4 maskColor = float4(0);
        
        if (invert > 0){
            maskColor = textureColor;
            textureColor = float4(0);
        }
        
        inputAngle = fmod(inputAngle, 2 * pi);//In case inputAngle > 2pi or inputAngle < -2pi
        float x = cos(inputAngle) * ((inputCenter.y - location.y) / sin(inputAngle));
        float temp = (inputCenter.x - location.x);
        
        if ((inputAngle >= 0 && inputAngle <= pi) ||
            (inputAngle <= -pi && inputAngle > -2 * pi) ||
            (inputAngle == 2 * pi)) {
            if (x > temp) {
                return maskColor;
            }
            return textureColor;
        }
        else {
            if (x > temp) {
                return textureColor;
            }
            return maskColor;
        }
    }
    
    //MARK: Star field(https://www.shadertoy.com/view/XlfGRj) by Pablo Román
    float4 starField(float4 inputExtent, float inputTime, float2 inputCenter, destination dest) {
        const int iterations = 17;
        const float formuparam = 0.53;
        
        const int volsteps = 20;
        const float stepsize = 0.1;
        
        const float zoom   = 0.800;
        const float tile   = 0.850;
        const float speed  = 0.010;
        
        const float brightness = 0.0015;
        const float darkmatter = 0.300;
        const float distfading = 0.730;
        const float saturation = 0.850;
        
        float2 fragCoord = dest.coord();
        float2 iResolution = inputExtent.zw;
        
        //get coords and direction
        float2 uv = fragCoord.xy / iResolution.xy - 0.5;
        uv.y *= iResolution.y / iResolution.x;
        float3 dir = float3(uv*zoom, 1.0);
        float time = inputTime * speed + 0.25;
        
        //mouse rotation
        float2 iMouse = inputCenter;
        float a1 = .5 + iMouse.x / iResolution.x * 2.;
        float a2 = .8 + iMouse.y / iResolution.y * 2.;
        float2x2 rot1 = float2x2(cos(a1),sin(a1),-sin(a1),cos(a1));
        float2x2 rot2 = float2x2(cos(a2),sin(a2),-sin(a2),cos(a2));
        dir.xz = dir.xz * rot1;
        dir.xy = dir.xy * rot2;
        float3 from = float3(1.,.5,0.5);
        from += float3(time*2.,time,-2.);
        from.xz = from.xz * rot1;
        from.xy = from.xy * rot2;
        
        //volumetric rendering
        float s = 0.1, fade = 1.;
        float3 v = float3(0.0);
        for (int r = 0; r<volsteps; r++) {
            float3 p = from + s * dir * 0.5;
            p = abs(float3(tile) - fmod(p, float3(tile * 2.))); // tiling fold
            float pa,a = pa = 0.;
            for (int i = 0; i < iterations; i++) {
                p = abs(p) / dot(p,p) - formuparam; // the magic formula
                a += abs(length(p) - pa); // absolute sum of average change
                pa = length(p);
            }
            float dm = max(0.,darkmatter-a*a*.001); //dark matter
            a *= a*a; // add contrast
            if (r>6) { fade*=1.-dm; } // dark matter, don't render near
            
            v += fade;
            v += float3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
            fade *= distfading; // distance fading
            s += stepsize;
        }
        v = mix(float3(length(v)),v,saturation); //color adjust
        return float4(v*.01,1.);
    }

}}
