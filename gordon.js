/*
 *    Gordon: An open source Flash™ runtime written in pure JavaScript
 *
 *    Copyright (c) 2010 Tobias Schneider
 *    Gordon is freely distributable under the terms of the MIT license.
 */

(function(window, undefined){
    var win = window,
        doc = win.document,
        fromCharCode = String.fromCharCode,
        push = Array.prototype.push,
        min = Math.min,
        max = Math.max;
    
    Gordon = {
        debug: false,
        qualityValues: {
            LOW: "low",
            AUTO_LOW: "autolow",
            AUTO_HIGH: "autohigh",
            MEDIUM: "medium",
            HIGH: "high",
            BEST: "best"
        },
        scaleValues: {
            SHOW_ALL: "showall",
            NO_ORDER: "noorder",
            EXACT_FIT: "exactfit"
        },
        validSignatures: {
            SWF: "FWS",
            COMPRESSED_SWF: "CWS"
        },
        readyStates: {
            LOADING: 0,
            UNINITIALIZED: 1,
            LOADED: 2,
            INTERACTIVE: 3,
            COMPLETE: 4
        },
        tagCodes: {
            END: 0,
            SHOW_FRAME: 1,
            DEFINE_SHAPE: 2,
            PLACE_OBJECT: 4,
            REMOVE_OBJECT: 5,
            DEFINE_BITS: 6,
            DEFINE_BUTTON: 7,
            JPEG_TABLES: 8,
            SET_BACKGROUND_COLOR: 9,
            DEFINE_FONT: 10,
            DEFINE_TEXT: 11,
            DO_ACTION: 12,
            DEFINE_FONT_INFO: 13,
            DEFINE_SOUND: 14,
            START_SOUND: 15,
            DEFINE_BUTTON_SOUND: 17,
            SOUND_STREAM_HEAD: 18,
            SOUND_STREAM_BLOCK: 19,
            DEFINE_BITS_LOSSLESS: 20,
            DEFINE_BITS_JPEG2: 21,
            DEFINE_SHAPE2: 22,
            DEFINE_BUTTON_CXFORM: 23,
            PROTECT: 24,
            PLACE_OBJECT2: 26,
            REMOVE_OBJECT2: 28,
            DEFINE_SHAPE3: 32,
            DEFINE_TEXT2: 33,
            DEFINE_BUTTON2: 34,
            DEFINE_BITS_JPEG3: 35,
            DEFINE_BITS_LOSSLESS2: 36,
            DEFINE_EDIT_TEXT: 37,
            DEFINE_SPRITE: 39,
            FRAME_LABEL: 43,
            SOUND_STREAM_HEAD2: 45,
            DEFINE_MORPH_SHAPE: 46,
            DEFINE_FONT2: 48,
            EXPORT_ASSETS: 56,
            IMPORT_ASSETS: 57,
            ENABLE_DEBUGGER: 58,
            DO_INIT_ACTION: 59,
            DEFINE_VIDEO_STREAM: 60,
            VIDEO_FRAME: 61,
            DEFINE_FONT_INFO2: 62,
            ENABLE_DEBUGGER2: 64,
            SCRIPT_LIMITS: 65,
            SET_TAB_INDEX: 66,
            FILE_ATTRIBUTES: 69,
            PLACE_OBJECT3: 70,
            IMPORT_ASSETS2: 71,
            DEFINE_FONT_ALIGN_ZONES: 73,
            CSM_TEXT_SETTINGS: 74,
            DEFINE_FONT3: 75,
            SYMBOL_CLASS: 76,
            METADATA: 77,
            DEFINE_SCALING_GRID: 78,
            DO_ABC: 82,
            DEFINE_SHAPE4: 83,
            DEFINE_MORPH_SHAPE2: 84,
            DEFINE_SCENE_AND_FRAME_LABEL_DATA: 86,
            DEFINE_BINARY_DATA: 87,
            DEFINE_FONT_NAME: 88,
            START_SOUND2: 89,
            DEFINE_BITS_JPEG4: 90,
            DEFINE_FONT4: 91
        },
        controlTags: [0, 1, 4, 5, 15, 18, 19, 26, 28, 43, 45],
        tagNames: {},
        tagHandlers: {},
        fillStyleTypes: {
            SOLID: 0x00, 
            LINEAR_GRADIENT: 0x10, 
            RADIAL_GRADIENT: 0x12,
            FOCAL_RADIAL_GRADIENT: 0x13,
            REPEATING_BITMAP: 0x40, 
            CLIPPED_BITMAP: 0x41, 
            NON_SMOOTHED_REPEATING_BITMAP: 0x42,
            NON_SMOOTHED_CLIPPED_BITMAP: 0x43
        },
        spreadModes: {
            PAD: 0,
            REFLECT: 1,
            REPEAT: 2
        },
        interpolationModes: {
            RGB: 0,
            LINEAR_RGB: 1
        },
        styleChangeStates: {
            MOVE_TO: 0x01,
            LEFT_FILL_STYLE: 0x02,
            RIGHT_FILL_STYLE: 0x04,
            LINE_STYLE: 0x08,
            NEW_STYLES: 0x10
        },
        buttonStates: {
            UP: 0x01,
            OVER: 0x02,
            DOWN: 0x04,
            HIT: 0x08
        },
        mouseButtons: {
            LEFT: 1,
            RIGHT: 2,
            MIDDLE: 3
        },
        textStyleFlags: {
            HAS_FONT: 0x08,
            HAS_COLOR: 0x04,
            HAS_XOFFSET: 0x01,
            HAS_YOFFSET: 0x02
        },
        actionCodes: {
            NEXT_FRAME: 0x04,
            PREVIOUS_FRAME: 0x05,
            PLAY: 0x06,
            STOP: 0x07,
            TOGGLE_QUALITY: 0x08,
            STOP_SOUNDS: 0x09,
            ADD: 0x0a,
            SUBTRACT: 0x0b,
            MULTIPLY: 0x0c,
            DIVIDE: 0x0d,
            EQUALS: 0x0e,
            LESS: 0x0f,
            AND: 0x10,
            OR: 0x11,
            NOT: 0x12,
            STRING_EQUALS: 0x13,
            STRING_LENGTH: 0x14,
            STRING_EXTRACT: 0x15,
            POP: 0x17,
            TO_INTEGER: 0x18,
            GET_VARIABLE: 0x1c,
            SET_VARIABLE: 0x1d,
            SET_TARGET2: 0x20,
            STRING_ADD: 0x21,
            GET_PROPERTY: 0x22,
            SET_PROPERTY: 0x23,
            CLONE_SPRITE: 0x24,
            REMOVE_SPRITE: 0x25,
            TRACE: 0x26,
            START_DRAG: 0x27,
            END_DRAG: 0x28,
            STRING_LESS: 0x29,
            THROW: 0x2a,
            CAST_OP: 0x2b,
            IMPLEMENTS_OP: 0x2c,
            FS_COMMAND2: 0x2d,
            RANDOM_NUMBER: 0x30,
            MBSTRING_LENGTH: 0x31,
            CHAR_TO_ASCII: 0x32,
            ASCII_TO_CHAR: 0x33,
            GET_TIME: 0x34,
            MBSTRING_EXTRACT: 0x35,
            MBCHAR_TO_ASCII: 0x36,
            MBASCII_TO_CHAR: 0x37,
            DELETE: 0x3a,
            DELETE2: 0x3b,
            DEFINE_LOCAL: 0x3c,
            CALL_FUNCTION: 0x3d,
            RETURN: 0x3e,
            MODULO: 0x3f,
            NEW_OBJECT: 0x40,
            DEFINE_LOCAL2: 0x41,
            INIT_ARRAY: 0x42,
            INIT_OBJECT: 0x43,
            TYPE_OF: 0x44,
            TARGET_PATH: 0x45,
            ENUMERATE: 0x46,
            ADD2: 0x47,
            LESS2: 0x48,
            EQUALS2: 0x49,
            TO_NUMBER: 0x4a,
            TO_STRING: 0x4b,
            PUSH_DUPLICATE: 0x4c,
            STACK_SWAP: 0x4d,
            GET_MEMBER: 0x4e,
            SET_MEMBER: 0x4f,
            INCREMENT: 0x50,
            DECREMENT: 0x51,
            CALL_METHOD: 0x52,
            NEW_METHOD: 0x53,
            INSTANCE_OF: 0x54,
            ENUMERATE2: 0x55,
            DO_INIT_ACTION: 0x59,
            BIT_AND: 0x60,
            BIT_OR: 0x61,
            BIT_XOR: 0x62,
            BIT_LSHIFT: 0x63,
            BIT_RSHIFT: 0x64,
            BIT_URSHIFT: 0x65,
            STRICT_EQUALS: 0x66,
            GREATER: 0x67,
            STRING_GREATER: 0x68,
            EXTENDS: 0x69,
            GOTO_FRAME: 0x81,
            DO_ABC: 0x82,
            GET_URL: 0x83,
            STORE_REGISTER: 0x87,
            CONSTANT_POOL: 0x88,
            WAIT_FOR_FRAME: 0x8a,
            SET_TARGET: 0x8b,
            SET_GO_TO_LABEL: 0x8c,
            WAIT_FOR_FRAME2: 0x8d,
            DEFINE_FUNCTION2: 0x8e,
            TRY: 0x8f,
            WITH: 0x94,
            PUSH: 0x96,
            JUMP: 0x99,
            GET_URL2: 0x9a,
            DEFINE_FUNCTION: 0x9b,
            IF: 0x9d,
            CALL: 0x9e,
            GOTO_FRAME2: 0x9f
        },
        valueTypes: {
            STRING: 0,
            FLOATING_POINT: 1,
            NULL: 2,
            UNDEFINED: 3,
            REGISTER: 4,
            BOOLEAN: 5,
            DOUBLE: 6,
            INTEGER: 7,
            CONSTANT8: 8,
            SWIFF_CONSTANT16: 9
        },
        urlTargets: {
            SELF: "_self",
            BLANK: "_blank",
            PARENT: "_parent",
            TOP: "_top"
        },
        bitmapFormats: {
            COLORMAPPED: 3,
            RGB15: 4,
            RGB24: 5
        },
        placeFlags: {
            MOVE: 0x01,
            HAS_CHARACTER: 0x02,
            HAS_MATRIX: 0x04,
            HAS_CXFORM: 0x08,
            HAS_RATIO: 0x10,
            HAS_NAME: 0x20,
            HAS_CLIP_DEPTH: 0x40,
            HAS_CLIP_ACTIONS: 0x80
        },
        defaultRenderer: null
    };
    
    (function(){
        var t = Gordon.tagCodes,
            n = Gordon.tagNames,
            h = Gordon.tagHandlers;
        for(var name in t){
            var code = t[name];
            n[code] = name;
            h[code] = "_handle" + name.toLowerCase().replace(/(^|_)([a-z])/g, function(match, p1, p2){
                return p2.toUpperCase();
            });
        }
    })();
    
    var console = window.console || {
        log: function(){}
    }
    
    function trace(){
        if(Gordon.debug){ console.log.apply(console, arguments); }
    }
    
    (function(){
        var DEFLATE_CODE_LENGTH_ORDER = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15],
            DEFLATE_CODE_LENGHT_MAP = [
                [0, 3], [0, 4], [0, 5], [0, 6], [0, 7], [0, 8], [0, 9], [0, 10], [1, 11], [1, 13], [1, 15], [1, 17],
                [2, 19], [2, 23], [2, 27], [2, 31], [3, 35], [3, 43], [3, 51], [3, 59], [4, 67], [4, 83], [4, 99],
                [4, 115], [5, 131], [5, 163], [5, 195], [5, 227], [0, 258]
            ],
            DEFLATE_DISTANCE_MAP = [
                [0, 1], [0, 2], [0, 3], [0, 4], [1, 5], [1, 7], [2, 9], [2, 13], [3, 17], [3, 25], [4, 33], [4, 49],
                [5, 65], [5, 97], [6, 129], [6, 193], [7, 257], [7, 385], [8, 513], [8, 769], [9, 1025], [9, 1537],
                [10, 2049], [10, 3073], [11, 4097], [11, 6145], [12, 8193], [12, 12289], [13, 16385], [13, 24577]
            ];
        
        Gordon.Stream = function(data){
            var buff = [],
                t = this,
                i = t.length = data.length;
            t.offset = 0;
            for(var i = 0; data[i]; i++){ buff.push(fromCharCode(data.charCodeAt(i) & 0xff)); }
            t._buffer = buff.join('');
            t._bitBuffer = null;
            t._bitOffset = 8;
        };
        Gordon.Stream.prototype = {
            readByteAt: function(pos){
                return this._buffer.charCodeAt(pos);
            },
            
            readNumber: function(numBytes, bigEnd){
                var t = this,
                    val = 0;
                if(bigEnd){
                    while(numBytes--){ val = (val << 8) | t.readByteAt(t.offset++); }
                }else{
                    var o = t.offset,
                        i = o + numBytes;
                    while(i > o){ val = (val << 8) | t.readByteAt(--i); }
                    t.offset += numBytes;
                }
                t.align();
                return val;
            },
            
            readSNumber: function(numBytes, bigEnd){
                var val = this.readNumber(numBytes, bigEnd),
                    numBits = numBytes * 8;
                if(val >> (numBits - 1)){ val -= Math.pow(2, numBits); }
                return val;
            },
            
            readSI8: function(){
                return this.readSNumber(1);
            },
            
            readSI16: function(bigEnd){
                return this.readSNumber(2, bigEnd);
            },
            
            readSI32: function(bigEnd){
                return this.readSNumber(4, bigEnd);
            },
            
            readUI8: function(){
                return this.readNumber(1);
            },
            
            readUI16: function(bigEnd){
                return this.readNumber(2, bigEnd);
            },
            
            readUI24: function(bigEnd){
                return this.readNumber(3, bigEnd);
            },
            
            readUI32: function(bigEnd){
                return this.readNumber(4, bigEnd);
            },
            
            readFixed: function(){
                return this._readFixedPoint(32, 16);
            },
            
            _readFixedPoint: function(numBits, precision){
                return this.readSB(numBits) * Math.pow(2, -precision);
            },
            
            readFixed8: function(){
                return this._readFixedPoint(16, 8);
            },
            
            readFloat: function(){
                return this._readFloatingPoint(8, 23);
            },
            
            _readFloatingPoint: function(numEBits, numSBits){
                var numBits = 1 + numEBits + numSBits,
                    numBytes = numBits / 8,
                    t = this,
                    val = 0.0;
                if(numBytes > 4){
                    var i = Math.ceil(numBytes / 4);
                    while(i--){
                        var buff = [],
                            o = t.offset,
                            j = o + (numBytes >= 4 ? 4 : numBytes % 4);
                        while(j > o){
                            buff.push(t.readByteAt(--j));
                            numBytes--;
                            t.offset++;
                        }
                    }
                    var s = new Gordon.Stream(fromCharCode.apply(String, buff)),
                        sign = s.readUB(1),
                        expo = s.readUB(numEBits),
                        mantis = 0,
                        i = numSBits;
                    while(i--){
                        if(s.readBool()){ mantis += Math.pow(2, i); }
                    }
                }else{
                    var sign = t.readUB(1),
                        expo = t.readUB(numEBits),
                        mantis = t.readUB(numSBits);
                }
                if(sign || expo || mantis){
                    var maxExpo = Math.pow(2, numEBits),
                        bias = ~~((maxExpo - 1) / 2),
                        scale = Math.pow(2, numSBits),
                        fract = mantis / scale;
                    if(bias){
                        if(bias < maxExpo){ val = Math.pow(2, expo - bias) * (1 + fract); }
                        else if(fract){ val = NaN; }
                        else{ val = Infinity; }
                    }else if(fract){ val = Math.pow(2, 1 - bias) * fract; }
                    if(NaN != val && sign){ val *= -1; }
                }
                return val;
            },
            
            readFloat16: function(){
                return this._readFloatingPoint(5, 10);
            },
            
            readDouble: function(){
                return this._readFloatingPoint(11, 52);
            },
            
            readEncodedU32: function(){
                var val = 0;
                for(var i = 0; i < 5; i++){
                    var num = this.readByteAt(this._offset++);
                    val = val | ((num & 0x7f) << (7 * i));
                    if(!(num & 0x80)){ break; }
                }
                return val;
            },
            
            readSB: function(numBits){
                var val = this.readUB(numBits);
                if(val >> (numBits - 1)){ val -= Math.pow(2, numBits); }
                return val;
            },
            
            readUB: function(numBits, lsb){
                var t = this,
                    val = 0;
                for(var i = 0; i < numBits; i++){
                    if(8 == t._bitOffset){
                        t._bitBuffer = t.readUI8();
                        t._bitOffset = 0;
                    }
                    if(lsb){ val |= (t._bitBuffer & (0x01 << t._bitOffset++) ? 1 : 0) << i; }
                    else{ val = (val << 1) | (t._bitBuffer & (0x80 >> t._bitOffset++) ? 1 : 0); }
                }
                return val;
            },
            
            readFB: function(numBits){
                return this._readFixedPoint(numBits, 16);
            },
            
            readString: function(numChars){
                var t = this,
                    b = t._buffer;
                if(undefined != numChars){
                    var str = b.substr(t.offset, numChars);
                    t.offset += numChars;
                }else{
                    var chars = [],
                        i = t.length - t.offset;
                    while(i--){
                        var code = t.readByteAt(t.offset++);
                        if(code){ chars.push(fromCharCode(code)); }
                        else{ break; }
                    }
                    var str = chars.join('');
                }
                return str;
            },
            
            readBool: function(numBits){
                return !!this.readUB(numBits || 1);
            },
            
            seek: function(offset, absolute){
                var t = this;
                t.offset = (absolute ? 0 : t.offset) + offset;
                t.align();
                return t;
            },
            
            align: function(){
                this._bitBuffer = null;
                this._bitOffset = 8;
                return this;
            },
            
            readLanguageCode: function(){
                return this.readUI8();
            },
            
            readRGB: function(){
                return {
                    red: this.readUI8(),
                    green: this.readUI8(),
                    blue: this.readUI8()
                }
            },
            
            readRGBA: function(){
                var rgba = this.readRGB();
                rgba.alpha = this.readUI8() / 255;
                return rgba;
            },
            
            readARGB: function(){
                var alpha = this.readUI8() / 255,
                    rgba = this.readRGB();
                rgba.alpha = alpha;
                return rgba;
            },
            
            readRect: function(){
                var t = this;
                    numBits = t.readUB(5),
                    rect = {
                        left: t.readSB(numBits),
                        right: t.readSB(numBits),
                        top: t.readSB(numBits),
                        bottom: t.readSB(numBits)
                    };
                t.align();
                return rect;
            },
            
            readMatrix: function(){
                var t = this,
                    hasScale = t.readBool();
                if(hasScale){
                    var numBits = t.readUB(5),
                        scaleX = t.readFB(numBits),
                        scaleY = t.readFB(numBits);
                }else{ var scaleX = scaleY = 1.0; }
                var hasRotation = t.readBool();
                if(hasRotation){
                    var numBits = t.readUB(5),
                        skewX = t.readFB(numBits),
                        skewY = t.readFB(numBits);
                }else{ var skewX =  skewY = 0.0; }
                var numBits = t.readUB(5);
                    matrix = {
                        scaleX: scaleX, scaleY: scaleY,
                        skewX: skewX, skewY: skewY,
                        moveX: t.readSB(numBits), moveY: t.readSB(numBits)
                    };
                t.align();
                return matrix;
            },
            
            readCxform: function(){
                return this._readCxf();
            },
            
            readCxformA: function(){
                return this._readCxf(true);
            },
            
            _readCxf: function(withAlpha){
                var t = this;
                    hasAddTerms = t.readBool(),
                    hasMultTerms = t.readBool(),
                    numBits = t.readUB(4);
                if(hasMultTerms){
                    var multR = t.readSB(numBits) / 256,
                        multG = t.readSB(numBits) / 256,
                        multB = t.readSB(numBits) / 256,
                        multA = withAlpha ? t.readSB(numBits) / 256 : 1;
                }else{ var multR = multG = multB = multA = 1; }
                if(hasAddTerms){
                    var addR = t.readSB(numBits),
                        addG = t.readSB(numBits),
                        addB = t.readSB(numBits),
                        addA = withAlpha ? t.readSB(numBits) / 256 : 0;
                }else{ var addR = addG = addB = addA = 0; }
                var cxform = {
                    multR: multR, multG: multG, multB: multB, multA: multA,
                    addR: addR, addG: addG, addB: addB, addA: addA
                }
                t.align();
                return cxform;
            },
            
            decompress: function(){
                var t = this,
                    b = t._buffer,
                    o = t.offset,
                    data = b.substr(0, o) + t.unzip();
                t.length = data.length;
                t.offset = o;
                t._buffer = data;
                return t;
            },
            
            unzip: function uz(raw){
                var t = this,
                    buff = [],
                    o = DEFLATE_CODE_LENGTH_ORDER,
                    m = DEFLATE_CODE_LENGHT_MAP,
                    d = DEFLATE_DISTANCE_MAP;
                t.seek(2);
                do{
                    var isFinal = t.readUB(1, true),
                        type = t.readUB(2, true);
                    if(type){
                        if(1 == type){
                            var distTable = uz.fixedDistTable,
                                litTable = uz.fixedLitTable;
                            if(!distTable){
                                var bitLengths = [];
                                for(var i = 0; i < 32; i++){ bitLengths.push(5); }
                                distTable = uz.fixedDistTable = buildHuffTable(bitLengths);
                            }
                            if(!litTable){
                                var bitLengths = [];
                                for(var i = 0; i <= 143; i++){ bitLengths.push(8); }
                                for(; i <= 255; i++){ bitLengths.push(9); }
                                for(; i <= 279; i++){ bitLengths.push(7); }
                                for(; i <= 287; i++){ bitLengths.push(8); }
                                litTable = uz.fixedLitTable = buildHuffTable(bitLengths);
                            }
                        }else{
                            var numLitLengths = t.readUB(5, true) + 257,
                                numDistLengths = t.readUB(5, true) + 1,
                                numCodeLenghts = t.readUB(4, true) + 4,
                                codeLengths = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                            for(var i = 0; i < numCodeLenghts; i++){ codeLengths[o[i]] = t.readUB(3, true); }
                            var codeTable = buildHuffTable(codeLengths),
                                litLengths = [],
                                prevCodeLen = 0,
                                maxLengths = numLitLengths + numDistLengths;
                            while(litLengths.length < maxLengths){
                                var sym = decodeSymbol(t, codeTable);
                                switch(sym){
                                    case 16:
                                        var i = t.readUB(2, true) + 3;
                                        while(i--){ litLengths.push(prevCodeLen); }
                                        break;
                                    case 17:
                                        var i = t.readUB(3, true) + 3;
                                        while(i--){ litLengths.push(0); }
                                        break;
                                    case 18:
                                        var i = t.readUB(7, true) + 11;
                                        while(i--){ litLengths.push(0); }
                                        break;
                                    default:
                                        if(sym <= 15){
                                            litLengths.push(sym);
                                            prevCodeLen = sym;
                                        }
                                }
                            }
                            var distTable = buildHuffTable(litLengths.splice(numLitLengths, numDistLengths)),
                                litTable = buildHuffTable(litLengths);
                        }
                        do{
                            var sym = decodeSymbol(t, litTable);
                            if(sym < 256){ buff.push(raw ? sym : fromCharCode(sym)); }
                            else if(sym > 256){
                                var lengthMap = m[sym - 257],
                                    len = lengthMap[1] + t.readUB(lengthMap[0], true),
                                    distMap = d[decodeSymbol(t, distTable)],
                                    dist = distMap[1] + t.readUB(distMap[0], true),
                                    i = buff.length - dist;
                                while(len--){ buff.push(buff[i++]); }
                            }
                        }while(256 != sym);
                    }else{
                        t.align();
                        var len = t.readUI16(),
                            nlen = t.readUI16();
                        if(raw){ while(len--){ buff.push(t.readUI8()); } }
                        else{ buff.push(t.readString(len)); }
                    }
                }while(!isFinal);
                t.seek(4);
                return raw ? buff : buff.join('');
            }
        };
        
        function buildHuffTable(bitLengths){
            var numLengths = bitLengths.length,
                blCount = [],
                maxBits = max.apply(Math, bitLengths),
                nextCode = [],
                code = 0,
                table = {},
                i = numLengths;
            while(i--){
                var len = bitLengths[i];
                blCount[len] = (blCount[len] || 0) + (len > 0);
            }
            for(var i = 1; i <= maxBits; i++){
                var len = i - 1;
                if(undefined == blCount[len]){ blCount[len] = 0; }
                code = (code + blCount[i - 1]) << 1;
                nextCode[i] = code;
            }
            for(var i = 0; i < numLengths; i++){
                var len = bitLengths[i];
                if(len){
                    table[nextCode[len]] = {
                        length: len,
                        symbol: i
                    };
                    nextCode[len]++;
                }
            }
            return table;
        }
        
        function decodeSymbol(s, table) {
            var code = 0,
                len = 0;
            while(true){
                code = (code << 1) | s.readUB(1, true);
                len++;
                var entry = table[code];
                if(undefined != entry && entry.length == len){ return entry.symbol }
            }
        }
    })();
    
    (function(){
        if(doc && window.Worker){
            var REGEXP_SCRIPT_SRC = /(^|.*\/)gordon.(min\.)?js$/,
                scripts = doc.getElementsByTagName("script"),
                src = '',
                i = scripts.length;
            while(i--){
                var path = scripts[i].src;
                if(REGEXP_SCRIPT_SRC.test(path)){
                    src = path;
                    break;
                }
            }
            worker = new Worker(src);
            
            Gordon.Parser = function(data, ondata){
                var t = this,
                    w = t._worker = worker;
                t.data = data;
                t.ondata = ondata;
                
                w.onmessage = function(e){
                    t.ondata(e.data);
                };
                
                w.postMessage(data);
            };
        }else{
            Gordon.Parser = function(url, ondata){
                var xhr = new XMLHttpRequest(),
                    t = this;
                xhr.open("GET", url, false);
                xhr.overrideMimeType("text/plain; charset=x-user-defined");
                xhr.send();
                if(200 != xhr.status){ throw new Error("Unable to load " + url + " status: " + xhr.status); }
                if(ondata) { t.ondata = ondata; }
                var s = t._stream = new Gordon.Stream(xhr.responseText),
                    sign = s.readString(3),
                    v = Gordon.validSignatures,
                    version = s.readUI8(),
                    fileLen = s.readUI32(),
                    h = Gordon.tagHandlers,
                    f = Gordon.tagCodes.SHOW_FRAME;
                if(sign == v.COMPRESSED_SWF){ s.decompress(); }
                else if(sign != v.SWF){ throw new Error(url + " is not a SWF movie file"); }
                this.ondata({
                    type: "header",
                    version: version,
                    fileLength: fileLen,
                    frameSize: s.readRect(),
                    frameRate: s.readUI16() / 256,
                    frameCount: s.readUI16()
                });
                t._dictionary = {};
                t._jpegTables = null;
                do{
                    var frm = {
                        type: "frame",
                        displayList: {}
                    };
                    do{
                        var hdr = s.readUI16(),
                            code = hdr >> 6,
                            len = hdr & 0x3f,
                            handl = h[code];
                        if(0x3f == len){ len = s.readUI32(); }
                        var offset = s.offset;
                        if(code){
                            if(code == f){
                                t.ondata(frm);
                                break;
                            }
                            if(t[handl]){ t[handl](s, offset, len, frm); }
                            else{ s.seek(len); }
                        }
                    }while(code && code != f);
                }while(code);
            };
            Gordon.Parser.prototype = {
                ondata: function(data){
                    postMessage(data);
                },
                
                _handleDefineShape: function(s, offset, len, frm, withAlpha){
                    var id = s.readUI16(),
                        shape = {
                            type: "shape",
                            id: id,
                            bounds: s.readRect()
                        }
                        t = this,
                        fillStyles = t._readFillStyles(s, withAlpha),
                        lineStyles = t._readLineStyles(s, withAlpha),
                        edges = t._readEdges(s, fillStyles, lineStyles, withAlpha);
                    if(edges instanceof Array){
                        var segments = shape.segments = [];
                        for(var i = 0, seg = edges[0]; seg; seg = edges[++i]){ segments.push({
                            type: "shape",
                            id: id + '-' + (i + 1),
                            commands: edges2cmds(seg.records, !!seg.line),
                            fill: seg.fill,
                            line: seg.line
                        }); }
                    }else{
                        shape.commands = edges2cmds(edges.records, !!edges.line),
                        shape.fill = edges.fill,
                        shape.line = edges.line
                    }
                    t.ondata(shape);
                    t._dictionary[id] = shape;
                    return t;
                },
                
                _readEdges: function(s, fillStyles, lineStyles, withAlpha, morph){
                    var numFillBits = s.readUB(4),
                        numLineBits = s.readUB(4),
                        x1 = 0,
                        y1 = 0,
                        x2 = 0,
                        y2 = 0,
                        seg = [],
                        i = 0,
                        isFirst = true,
                        edges = [],
                        leftFill = 0,
                        rightFill = 0,
                        fsOffset = 0,
                        lsOffset = 0,
                        leftFillEdges = {},
                        rightFillEdges = {},
                        line = 0,
                        lineEdges = {},
                        c = Gordon.styleChangeStates,
                        countFChanges = 0,
                        countLChanges = 0,
                        useSinglePath = true;
                    do{
                        var type = s.readUB(1),
                            flags = null;
                        if(type){
                            var isStraight = s.readBool(),
                                numBits = s.readUB(4) + 2,
                                cx = null,
                                cy = null;
                            x1 = x2;
                            y1 = y2;
                            if(isStraight){
                                var isGeneral = s.readBool();
                                if(isGeneral){
                                    x2 += s.readSB(numBits);
                                    y2 += s.readSB(numBits);
                                }else{
                                    var isVertical = s.readBool();
                                        if(isVertical){ y2 += s.readSB(numBits); }
                                        else{ x2 += s.readSB(numBits); }
                                    }
                            }else{
                                cx = x1 + s.readSB(numBits);
                                cy = y1 + s.readSB(numBits);
                                x2 = cx + s.readSB(numBits);
                                y2 = cy + s.readSB(numBits);
                            }
                            seg.push({
                                i: i++,
                                f: isFirst,
                                x1: x1, y1: y1,
                                cx: cx, cy: cy,
                                x2: x2, y2: y2
                            });
                            isFirst = false;
                        }else{
                            if(seg.length){
                                push.apply(edges, seg);
                                if(leftFill){
                                    var idx = fsOffset + leftFill,
                                        list = leftFillEdges[idx] || (leftFillEdges[idx] = []);
                                    for(var j = 0, edge = seg[0]; edge; edge = seg[++j]){
                                        var e = cloneEdge(edge),
                                            tx1 = e.x1,
                                            ty1 = e.y1;
                                        e.i = i++;
                                        e.x1 = e.x2;
                                        e.y1 = e.y2;
                                        e.x2 = tx1;
                                        e.y2 = ty1;
                                        list.push(e);
                                    }
                                }
                                if(rightFill){
                                    var idx = fsOffset + rightFill,
                                        list = rightFillEdges[idx] || (rightFillEdges[idx] = []);
                                    push.apply(list, seg);
                                }
                                if(line){
                                    var idx = lsOffset + line,
                                        list = lineEdges[idx] || (lineEdges[idx] = []);
                                    push.apply(list, seg);
                                }
                                seg = [];
                                isFirst = true;
                            }
                            var flags = s.readUB(5);
                            if(flags){
                                if(flags & c.MOVE_TO){
                                    var numBits = s.readUB(5);
                                    x2 = s.readSB(numBits);
                                    y2 = s.readSB(numBits);
                                }
                                if(flags & c.LEFT_FILL_STYLE){
                                    leftFill = s.readUB(numFillBits);
                                    countFChanges++;
                                }
                                if(flags & c.RIGHT_FILL_STYLE){
                                    rightFill = s.readUB(numFillBits);
                                    countFChanges++;
                                }
                                if(flags & c.LINE_STYLE){
                                    line = s.readUB(numLineBits);
                                    countLChanges++;
                                }
                                if((leftFill && rightFill) || countFChanges + countLChanges > 2){ useSinglePath = false; }
                                if(flags & c.NEW_STYLES){
                                    fsOffset = fillStyles.length;
                                    lsOffset = lineStyles.length;
                                    push.apply(fillStyles, t._readFillStyles(s, withAlpha || morph));
                                    push.apply(lineStyles, t._readLineStyles(s, withAlpha || morph));
                                    numFillBits = s.readUB(4);
                                    numLineBits = s.readUB(4);
                                    useSinglePath = false;
                                }
                            }
                        }
                    }while(type || flags);
                    s.align();
                    if(useSinglePath){
                        var fill = leftFill || rightFill;
                        return {
                            records: edges,
                            fill: fill ? fillStyles[fsOffset + fill - 1] : null,
                            line: lineStyles[lsOffset + line - 1]
                        };
                    }else{
                        var segments = [];
                        for(var i = 0; fillStyles[i]; i++){
                            var fill = i + 1,
                                list = leftFillEdges[fill],
                                fillEdges = [],
                                edgeMap = {};
                            if(list){ push.apply(fillEdges, list); }
                            list = rightFillEdges[fill];
                            if(list){ push.apply(fillEdges, list); }
                            for(var j = 0, edge = fillEdges[0]; edge; edge = fillEdges[++j]){
                                var key = pt2key(edge.x1, edge.y1),
                                    list = edgeMap[key] || (edgeMap[key] = []);
                                list.push(edge);
                            }
                            var recs = [],
                                countFillEdges = fillEdges.length,
                                l = countFillEdges - 1;
                            for(var j = 0; j < countFillEdges && !recs[l]; j++){
                                var edge = fillEdges[j];
                                if(!edge.c){
                                    var seg = [],
                                        firstKey = pt2key(edge.x1, edge.y1),
                                        usedMap = {};
                                    do{
                                        seg.push(edge);
                                        usedMap[edge.i] = true;
                                        var key = pt2key(edge.x2, edge.y2),
                                            list = edgeMap[key],
                                            favEdge = fillEdges[j + 1],
                                            nextEdge = null;
                                        if(key == firstKey){
                                            var k = seg.length;
                                            while(k--){ seg[k].c = true; }
                                            push.apply(recs, seg);
                                            break;
                                        }
                                        if (!(list && list.length)){ break; }
                                        for(var k = 0; list[k]; k++){
                                            var entry = list[k];
                                            if(entry == favEdge && !entry.c){
                                                list.splice(k, 1);
                                                nextEdge = entry;
                                            }
                                        }
                                        if(!nextEdge){
                                            for(var k = 0; list[k]; k++){
                                                var entry = list[k];
                                                if(!(entry.c || usedMap[entry.i])){ nextEdge = entry; }
                                            }
                                        }
                                        edge = nextEdge;
                                    }while(edge);
                                }
                            }
                            var l = recs.length;
                            if(l){ segments.push({
                                records: recs,
                                fill: fillStyles[i],
                                "_index": recs[l - 1].i
                            }); }
                        }
                        var i = lineStyles.length;
                        while(i--){
                            var recs = lineEdges[i + 1];
                            if(recs){ segments.push({
                                records: recs,
                                line: lineStyles[i],
                                _index: recs[recs.length - 1].i
                            }); }
                        }
                        segments.sort(function(a, b){
                            return a._index - b._index;
                        });
                        if(segments.length > 1){ return segments; }
                        else{ return segments[0]; }
                    }
                },
                
                _readFillStyles: function(s, withAlpha, morph){
                    var numStyles = s.readUI8(),
                        styles = [];
                    if(0xff == numStyles){ numStyles = s.readUI16(); }
                    while(numStyles--){
                        var type = s.readUI8(),
                            f = Gordon.fillStyleTypes;
                        switch(type){
                            case f.SOLID:
                                if(morph){ styles.push([s.readRGBA(), s.readRGBA()]); }
                                else{ styles.push(withAlpha ? s.readRGBA() : s.readRGB()); }
                                break;
                            case f.LINEAR_GRADIENT:
                            case f.RADIAL_GRADIENT:
                                if(morph){ var matrix = [nlizeMatrix(s.readMatrix()), nlizeMatrix(s.readMatrix())]; }
                                else{ var matrix = nlizeMatrix(s.readMatrix()); }
                                var stops = [],
                                    style = {
                                        type: type == f.LINEAR_GRADIENT ? "linear" : "radial",
                                        matrix: matrix,
                                        spread: morph ? Godon.spreadModes.PAD : s.readUB(2),
                                        interpolation: morph ? Godon.interpolationModes.RGB : s.readUB(2),
                                        stops: stops
                                    },
                                    numStops = s.readUB(4);
                                while(numStops--){
                                    var offset = s.readUI8() / 256,
                                        color = withAlpha || morph ? s.readRGBA() : s.readRGB();
                                    stops.push({
                                        offset: morph ? [offset, s.readUI8() / 256] : offset,
                                        color: morph ? [color, s.readRGBA()] : color
                                    });
                                }
                                styles.push(style);
                                break;
                            case f.REPEATING_BITMAP:
                            case f.CLIPPED_BITMAP:
                                var imgId = s.readUI16(),
                                    img = this._dictionary[imgId],
                                    matrix = morph ? [s.readMatrix(), s.readMatrix()] : s.readMatrix();
                                if(img){
                                    styles.push({
                                        type: "pattern",
                                        image: img,
                                        matrix: matrix,
                                        repeat: type == f.REPEATING_BITMAP
                                    });
                                }else{ styles.push(null); }
                                break;
                        }
                    }
                    return styles;
                },
                
                _readLineStyles: function(s, withAlpha, morph){
                    var numStyles = s.readUI8(),
                        styles = [];
                    if(0xff == numStyles){ numStyles = s.readUI16(); }
                    while(numStyles--){
                        var width = s.readUI16(),
                            color = withAlpha || morph ? s.readRGBA() : s.readRGB()
                        styles.push({
                            width: morph ? [width, s.readUI16()] : width,
                            color: morph ? [color, s.readRGBA()] : color
                        });
                    }
                    return styles;
                },
                
                _handlePlaceObject: function(s, offset, len, frm){
                    var objId = s.readUI16(),
                        depth = s.readUI16(),
                        t = this,
                        character = {
                            object: t._dictionary[objId].id,
                            depth: depth,
                            matrix: s.readMatrix()
                        };
                    if(s.offset - offset != len){ character.cxform = s.readCxform(); }
                    frm.displayList[depth] = character;
                    return t;
                },
                
                _handleRemoveObject: function(s, offset, len, frm){
                    var id = s.readUI16(),
                        depth = s.readUI16();
                    frm.displayList[depth] = null;
                    return this;
                },
                
                _handleDefineBits: function(s, offset, len, frm, withAlpha){
                    var id = s.readUI16(),
                        img = {
                            type: "image",
                            id: id,
                            width: 0,
                            height: 0
                        },
                        t = this,
                        h = t._jpegTables;
                    if(withAlpha){
                        var alphaDataOffset = s.readUI32(),
                            data = s.readString(alphaDataOffset);
                        img.alphaData = s.readString(len - (s.offset - offset));
                    }else{ var data = s.readString(len - 2); }
                    for(var i = 0; data[i]; i++){
                        var word = ((data.charCodeAt(i) & 0xff) << 8) | (data.charCodeAt(++i) & 0xff);
                        if(0xffd9 == word){
                            word = ((data.charCodeAt(++i) & 0xff) << 8) | (data.charCodeAt(++i) & 0xff);
                            if(word == 0xffd8){
                                data = data.substr(0, i - 4) + data.substr(i);
                                i -= 4;
                            }
                        }else if(0xffc0 == word){
                            i += 3;
                            img.height = ((data.charCodeAt(++i) & 0xff) << 8) | (data.charCodeAt(++i) & 0xff);
                            img.width = ((data.charCodeAt(++i) & 0xff) << 8) | (data.charCodeAt(++i) & 0xff);
                            break;
                        }
                    }
                    img.data = h ? h.substr(0, h.length - 2) + data.substr(2) : data;
                    t.ondata(img);
                    t._dictionary[id] = img;
                    return t;
                },
                
                _handleDefineButton: function(s, offset, len, frm, advanced){
                    var id = s.readUI16(),
                        t = this,
                        d = t._dictionary,
                        states = {},
                        button = {
                            type: "button",
                            id: id,
                            states: states,
                            trackAsMenu: advanced ? s.readBool(8) : false
                        };
                        if(advanced){ s.seek(2); }
                    do{
                        var flags = s.readUI8();
                        if(flags){
                            var objId = s.readUI16(),
                                depth = s.readUI16(),
                                state = 0x01,
                                character = {
                                    object: d[objId].id,
                                    depth: depth,
                                    matrix: s.readMatrix()
                                };
                                if(advanced){ character.cxform = s.readCxformA(); }
                            while(state <= 0x08){
                                if(flags & state){
                                    var list = states[state] || (states[state] = {});
                                    list[depth] = character;
                                }
                                state <<= 1;
                            }
                        }
                    }while(flags);
                    button.action = t._readAction(s, s.offset, len - (s.offset - offset));
                    t.ondata(button);
                    d[id] = button;
                    return t;
                },
                
                _readAction: function(s, offset, len){
                    s.seek(len - (s.offset - offset));
                    return '';
                },
                
                _handleJpegTables: function(s, offset, len){
                    this._jpegTables = s.readString(len);
                    return this;
                },
                
                _handleSetBackgroundColor: function(s, offset, len, frm){
                    frm.bgcolor = s.readRGB();
                    return this;
                },
                
                _handleDefineFont: function(s){
                    var id = s.readUI16(),
                        numGlyphs = s.readUI16() / 2,
                        glyphs = [],
                        t = this,
                        font = {
                            type: "font",
                            id: id,
                            glyphs: glyphs
                        };
                    s.seek(numGlyphs * 2 - 2);
                    while(numGlyphs--){ glyphs.push(t._readGlyph(s)); }
                    t.ondata(font);
                    t._dictionary[id] = font;
                    return t;
                },
                
                _readGlyph: function(s){
                    var numFillBits = s.readUB(4),
                        numLineBits = s.readUB(4),
                        x = 0,
                        y = 0,
                        cmds = [],
                        c = Gordon.styleChangeStates;
                    do{
                        var type = s.readUB(1),
                            flags = null;
                        if(type){
                            var isStraight = s.readBool(),
                                numBits = s.readUB(4) + 2;
                            if(isStraight){
                                var isGeneral = s.readBool();
                                if(isGeneral){
                                    x += s.readSB(numBits);
                                    y += s.readSB(numBits);
                                    cmds.push('L' + x + ',' + y);
                                }else{
                                    var isVertical = s.readBool();
                                    if(isVertical){
                                        y += s.readSB(numBits);
                                        cmds.push('V' + y);
                                    }else{
                                        x += s.readSB(numBits);
                                        cmds.push('H' + x);
                                    }
                                }
                            }else{
                                var cx = x + s.readSB(numBits),
                                    cy = y + s.readSB(numBits);
                                x = cx + s.readSB(numBits);
                                y = cy + s.readSB(numBits);
                                cmds.push('Q' + cx + ',' + cy + ',' + x + ',' + y);
                            }
                        }else{
                            var flags = s.readUB(5);
                            if(flags){
                                if(flags & c.MOVE_TO){
                                    var numBits = s.readUB(5);
                                    x = s.readSB(numBits);
                                    y = s.readSB(numBits);
                                    cmds.push('M' + x + ',' + y);
                                }
                                if(flags & c.LEFT_FILL_STYLE || flags & c.RIGHT_FILL_STYLE){ s.readUB(numFillBits); }
                            }
                        }
                    }while(type || flags);
                    s.align();
                    return {commands: cmds.join('')};
                },
                
                _handleDefineText: function(s, offset, length, frm, withAlpha){
                    var id = s.readUI16(),
                        strings = [],
                        txt = {
                            type: "text",
                            id: id,
                            bounds: s.readRect(),
                            matrix: s.readMatrix(),
                            strings: strings
                        },
                        numGlyphBits = s.readUI8(),
                        numAdvBits = s.readUI8(),
                        fontId = null,
                        fill = null,
                        x = 0,
                        y = 0,
                        size = 0,
                        str = null,
                        d = this._dictionary;
                    do{
                        var hdr = s.readUB(8);
                        if(hdr){
                            var type = hdr >> 7;
                            if(type){
                                var flags = hdr & 0x0f;
                                if(flags){
                                    var f = Gordon.textStyleFlags;
                                    if(flags & f.HAS_FONT){ fontId = s.readUI16(); }
                                    if(flags & f.HAS_COLOR){ fill = withAlpha ? s.readRGBA() : s.readRGB(); }
                                    if(flags & f.HAS_XOFFSET){ x = s.readSI16(); }
                                    if(flags & f.HAS_YOFFSET){ y = s.readSI16(); }
                                    if(flags & f.HAS_FONT){ size = s.readUI16(); }
                                }
                                str = {
                                    font: d[fontId].id,
                                    fill: fill,
                                    x: x,
                                    y: y,
                                    size: size,
                                    entries: []
                                };
                                strings.push(str);
                            }else{
                                var numGlyphs = hdr & 0x7f,
                                    entries = str.entries;
                                while(numGlyphs--){
                                    var idx = s.readUB(numGlyphBits),
                                        adv = s.readSB(numAdvBits);
                                    entries.push({
                                        index: idx,
                                        advance: adv
                                    });
                                    x += adv;
                                }
                                s.align();
                            }
                        }
                    }while(hdr);
                    this.ondata(txt);
                    d[id] = txt;
                    return this;
                },
                
                _handleDoAction: function(s, offset, len, frm){
                    frm.action = this._readAction(s, offset, len);
                    return this;
                },
                
                _handleDefineFontInfo: function(s, offset, len){
                    var d = this._dictionary,
                        fontId = s.readUI16(),
                        font = d[fontId],
                        codes = [],
                        f = font.info = {
                            name: s.readString(s.readUI8()),
                            isSmall: s.readBool(3),
                            isShiftJIS: s.readBool(),
                            isANSI: s.readBool(),
                            isItalic: s.readBool(),
                            isBold: s.readBool(),
                            codes: codes
                        },
                        u = f.isUTF8 = s.readBool(),
                        i = font.glyphs.length;
                    while(i--){ codes.push(u ? s.readUI16() : s.readUI8()); }
                    this.ondata(font);
                    d[fontId] = font;
                    return this;
                },
                
                _handleDefineBitsLossless: function(s, offset, len, frm, withAlpha){
                    var id = s.readUI16(),
                        format = s.readUI8(),
                        img = {
                            type: "image",
                            id: id,
                            width: s.readUI16(),
                            height: s.readUI16(),
                            withAlpha: withAlpha
                        };
                    if(format == Gordon.bitmapFormats.COLORMAPPED){ img.colorTableSize = s.readUI8() + 1; }
                    img.colorData = s.readString(len - (s.offset - offset));
                    this.ondata(img);
                    this._dictionary[id] = img;
                    return this;
                },
                
                _handleDefineBitsJpeg2: function(s, offset, len){
                    return this._handleDefineBits(s, offset, len);
                },
                
                _handleDefineShape2: function(s, offset, len){
                    return this._handleDefineShape(s, offset, len);
                },
                
                _handleDefineButtonCxform: function(s){
                    var t = this,
                        d = t._dictionary,
                        buttonId = s.readUI16(),
                        button = d[buttonId];
                    button.cxform = s.readCxform();
                    t.ondata(button);
                    d[buttonId] = button;
                    return t;
                },
                
                _handleProtect: function(s, offset, len){
                    s.seek(len);
                    return this;
                },
                
                _handlePlaceObject2: function(s, offset, len, frm){
                    var flags = s.readUI8(),
                        depth = s.readUI16(),
                        f = Gordon.placeFlags,
                        character = {depth: depth},
                        t = this;
                    if(flags & f.HAS_CHARACTER){
                        var objId = s.readUI16();
                        character.object = t._dictionary[objId].id;
                    }
                    if(flags & f.HAS_MATRIX){ character.matrix = s.readMatrix(); }
                    if(flags & f.HAS_CXFORM){ character.cxform = s.readCxformA(); }
                    if(flags & f.HAS_RATIO){ character.ratio = s.readUI16(); }
                    if(flags & f.HAS_NAME){ character.name = s.readString(); }
                    if(flags & f.HAS_CLIP_DEPTH){ character.clipDepth = s.readUI16(); }
                    if(flags & f.HAS_CLIP_ACTIONS){ s.seek(len - (s.offset - offset)) }
                    frm.displayList[depth] = character;
                    return t;
                },
                
                _handleRemoveObject2: function(s, offset, len, frm){
                    var depth = s.readUI16();
                    frm.displayList[depth] = null;
                    return this;
                },
                
                _handleDefineShape3: function(s, offset, len, frm){
                    return this._handleDefineShape(s, offset, len, frm, true);
                },
                
                _handleDefineText2: function(s, offset, len, frm){
                    return this._handleDefineText(s, offset, len, frm, true);
                },
                
                _handleDefineButton2: function(s, offset, len, frm){
                    return t._handleDefineButton(s, offset, len, frm, true);
                },
                
                _handleDefineBitsJpeg3: function(s, offset, len, frm){
                    return this._handleDefineBits(s, offset, len, frm, true);
                },
                
                _handleDefineBitsLossless2: function(s, offset, len, frm){
                    return this._handleDefineBitsLossless(s, offset, len, frm, true);
                },
                
                _handleDefineSprite: function(s, offset, len){
                    var id = s.readUI16(),
                        frameCount = s.readUI16(),
                        h = Gordon.tagHandlers,
                        f = Gordon.tagCodes.SHOW_FRAME,
                        c = Gordon.controlTags,
                        timeline = [],
                        sprite = {
                            id: id,
                            timeline: timeline
                        },
                        t = this;
                    do{
                        var frm = {
                            type: "frame",
                            displayList: {}
                        };
                        do{
                            var hdr = s.readUI16(),
                                code = hdr >> 6,
                                len = hdr & 0x3f,
                                handl = h[code];
                            if(0x3f == len){ len = s.readUI32(); }
                            var offset = s.offset;
                            if(code){
                                if(code == f){
                                    timeline.push(c);
                                    break;
                                }
                                if(c[code] && t[handl]){ t[handl](s, offset, len, frm); }
                                else{ s.seek(len); }
                            }
                        }while(code);
                    }while(code);
                    t.ondata(sprite);
                    t._dictionary[id] = sprite;
                    return t;
                },
                
                _handleFrameLabel: function(s, offset, len, frm){
                    frm.label = s.readString();
                    return this;
                },
                
                _handleDefineMorphShape: function(s, offset, len){
                    var id = s.readUI16(),
                        startBounds = s.readRect(),
                        endBounds = s.readRect(),
                        endEdgesOffset = s.readUI32(),
                        t = this,
                        fillStyles = t._readFillStyles(s, true, true),
                        lineStyles = t._readLineStyles(s, true, true),
                        morph = {
                            type: "morph",
                            id: id,
                            startEdges: t._readEdges(s, fillStyles, lineStyles, true, true),
                            endEdges: t._readEdges(s, fillStyles, lineStyles, true, true)
                        };
                    t.ondata(morph);
                    t._dictionary[id] = morph;
                    return t;
                },
                
                _handleDefineFont2: function(s, offset, len){
                    var id = s.readUI16(),
                        hasLayout = s.readBool(),
                        glyphs = [],
                        font = {
                            type: "font",
                            id: id,
                            glyphs: glyphs
                        },
                        codes = [],
                        f = font.info = {
                            isShiftJIS: s.readBool(),
                            isSmall: s.readBool(),
                            isANSI: s.readBool(),
                            useWideOffsets: s.readBool(),
                            isUTF8: s.readBool(),
                            isItalic: s.readBool(),
                            isBold: s.readBool(),
                            languageCode: s.readLanguageCode(),
                            name: s.readString(s.readUI8()),
                            codes: codes
                        },
                        i = numGlyphs = s.readUI16(),
                        w = f.useWideOffsets,
                        offsets = [],
                        tablesOffset = s.offset,
                        u = f.isUTF8;
                    while(i--){ offsets.push(w ? s.readUI32() : s.readUI16()); }
                    s.seek(w ? 4 : 2);
                    for(var i = 0, o = offsets[0]; o; o = offsets[++i]){
                        s.seek(tablesOffset + o, true);
                        glyphs.push(this._readGlyph(s));
                    }
                    var i = numGlyphs;
                    while(i--){ codes.push(u ? s.readUI16() : s.readUI8()); };
                    if(hasLayout){
                        f.ascent = s.readUI16();
                        f.descent = s.readUI16();
                        f.leading = s.readUI16();
                        var advanceTable = f.advanceTable = [],
                            boundsTable = f.boundsTable = [],
                            kerningTable = f.kerningTable = [];
                        i = numGlyphs;
                        while(i--){ advanceTable.push(s.readUI16()); };
                        i = numGlyphs;
                        while(i--){ boundsTable.push(s.readRect()); };
                        var kerningCount = s.readUI16();
                        while(kerningCount--){ kerningTable.push({
                            code1: u ? s.readUI16() : s.readUI8(),
                            code2: u ? s.readUI16() : s.readUI8(),
                            adjustment: s.readUI16()
                        }); }
                    }
                    this.ondata(font);
                    this._dictionary[id] = font;
                    return this;
                }
            };
            
            function nlizeMatrix(matrix){
                return {
                    scaleX: matrix.scaleX * 20, scaleY: matrix.scaleY * 20,
                    skewX: matrix.skewX * 20, skewY: matrix.skewY * 20,
                    moveX: matrix.moveX, moveY: matrix.moveY
                };
            }
            
            function cloneEdge(edge){
                return {
                    i: edge.i,
                    f: edge.f,
                    x1: edge.x1, y1: edge.y1,
                    cx: edge.cx, cy: edge.cy,
                    x2: edge.x2, y2: edge.y2
                };
            }
            
            function edges2cmds(edges, stroke){
                var firstEdge = edges[0],
                    x1 = 0,
                    y1 = 0,
                    x2 = 0,
                    y2 = 0,
                    cmds = [];
                for(var i = 0, edge = firstEdge; edge; edge = edges[++i]){
                    x1 = edge.x1;
                    y1 = edge.y1;
                    if(x1 != x2 || y1 != y2 || !i){ cmds.push('M' + x1 + ',' + y1); }
                    x2 = edge.x2;
                    y2 = edge.y2;
                    if(null == edge.cx || null == edge.cy){
                        if(x2 == x1){ cmds.push('V' + y2); }
                        else if(y2 == y1){ cmds.push('H' + x2); }
                        else{ cmds.push('L' + x2 + ',' + y2); }
                    }else{ cmds.push('Q' + edge.cx + ',' + edge.cy + ',' + x2 + ',' + y2); }
                };
                if(!stroke && (x2 != firstEdge.x1 || y2 != firstEdge.y1)){ cmds.push('L' + firstEdge.x1 + ',' + firstEdge.y1) }
                return cmds.join('');
            }
            
            function pt2key(x, y){
                return (x + 50000) * 100000 + y;
            }
            
            win.onmessage = function(e){
                new Gordon.Parser(e.data);
            };
        }
    })();
    
    (function(){
        var LOCATION_DIRNAME = win.location.href.replace(/[^\/]*$/, ''),
            defaults = {
                id: '',
                width: 0,
                height: 0,
                autoplay: true,
                loop: true,
                quality: Gordon.qualityValues.HIGH,
                scale: Gordon.scaleValues.SHOW_ALL,
                bgcolor: '',
                poster: '',
                renderer: null,
                onprogress: function(percent){},
                onreadystatechange: function(state){}
            };
            
        Gordon.Movie = function(url, options){
            var t = this,
                s = Gordon.readyStates;
            t.url = url;
            for(var prop in defaults){ t[prop] = prop in options ? options[prop] : defaults[prop]; }
            if(!url){ throw new Error("URL of a SWF movie file must be passed as first argument"); }
            t._startTime = +new Date;
            t.framesLoaded = 0;
            t.isPlaying = false;
            t.currentFrame = 0;
            t.currentLabel = undefined;
            t._readyState = s.UNINITIALIZED;
            t._changeReadyState(t._readyState);
            var d = t._dictionary = {},
                l = t._timeline = [];
            t._changeReadyState(s.LOADING);
            new Gordon.Parser((/^\w:\/\//.test(url) ? '' : LOCATION_DIRNAME) + url, function(obj){
                var action = obj.action;
                if(action){ eval("obj.action = function(){ " + action + "; }"); }
                switch(obj.type){
                    case "header":
                        for(var prop in obj){ t['_' + prop] = obj[prop]; }
                        var f = t._frameSize,
                            r = t.renderer = t.renderer || Gordon.SvgRenderer,
                            id = t.id;
                        if(!(t.width && t.height)){
                            t.width = (f.right - f.left) / 20;
                            t.height = (f.bottom - f.top) / 20;
                        };
                        t._renderer = new r(t.width, t.height, f, t.quality, t.scale, t.bgcolor);
                        t.totalFrames = t._frameCount;
                        if(id){
                            var stage = t._stage = doc.getElementById(id),
                                bgcolor = t.bgcolor,
                                bgParts = [],
                                poster = t.poster;
                            stage.innerHTML = '';
                            if(t.bgcolor){ bgParts.push(bgcolor); }
                            if(poster){ bgParts.push(poster, "center center"); }
                            if(bgParts.length){ stage.setAttribute("style", "background: " + bgParts.join(' ')); }
                        }
                        t._changeReadyState(s.LOADED);
                        break;
                    case "frame":
                        t._renderer.frame(obj);
                        l.push(obj);
                        var lbl = obj.label,
                            n = ++t.framesLoaded;
                        if(lbl){ t._labeledFrameNums[lbl] = n; }
                        t.onprogress(~~((n * 100) / t.totalFrames));
                        if(1 == n){
                            var stage = t._stage;
                            if(stage){
                                stage.appendChild(t._renderer.node);
                                t._changeReadyState(s.INTERACTIVE);
                            }
                            if(t.autoplay){ t.play(); }
                            else{ t.goTo(1); }
                        }
                        if(n == t.totalFrames){ t._changeReadyState(s.COMPLETE); }
                        break;
                    default:
                        t._renderer.define(obj);
                        d[obj.id] = obj;
                }
            });
        };
        Gordon.Movie.prototype = {
            _changeReadyState: function(state){
                this._readyState = state;
                this.onreadystatechange(state);
                return this;
            },
            
            play: function(){
                var t = this,
                    c = t.currentFrame,
                    timeout = 1000 / t._frameRate;
                t.isPlaying = true;
                if(c < t.totalFrames){
                    if(t.framesLoaded > c){ t.goTo(c + 1); }
                    else{ timeout = 0; }
                }else{
                    if(!t.loop){ return t.stop(); }
                    else{ t.goTo(1); }
                }
                setTimeout(function(){
                    if(t.isPlaying){ t.play() };
                }, timeout);
                return t;
            },
            
            next: function(){
                var t = this,
                    c = t.currentFrame;
                t.goTo(c < t.totalFrames ? c + 1 : 1);
                return t;
            },
            
            goTo: function gf(frmNumOrLabel){
                var t = this,
                    c = t.currentFrame,
                    r = t._renderer;
                if(gf.caller !== t.play){ t.stop(); }
                if(isNaN(frmNumOrLabel)){
                    var frmNum = t._labeledFrameNums[frmNumOrLabel];
                    if(frmNum){ t.goTo(frmNum); }
                }else if(frmNumOrLabel != c){
                    if(frmNumOrLabel < c){ c = t.currentFrame = 0; }
                    var l = t._timeline;
                    while(c != frmNumOrLabel){
                        c = ++t.currentFrame;
                        var idx = c - 1,
                            frm = l[idx],
                            action = frm.action;
                        r.show(idx);
                        t.currentLabel = frm.lbl;
                        if(action){ action.call(this); }
                    }
                }
                return t;
            },
            
            stop: function(){
                this.isPlaying = false;
                return this;
            },
            
            prev: function(){
                var t = this,
                    c = t.currentFrame;
                t.goTo(c > 1 ? c - 1 : t.totalFrames);
                return t;
            },
            
            rewind: function(){
                this.goTo(1);
                return this;
            },
            
            getURL: function(url, target){
                var u = Gordon.urlTargets;
                switch(target){
                    case u.BLANK:
                        win.open(url);
                        break;
                    case u.PARENT:
                        win.parent.location.href = url;
                        break;
                    case u.TOP:
                        win.top.location.href = url;
                        break;
                    default:
                        win.location.href = url;
                }
                return this;
            },
            
            toggleQuality: function thq(){
                var o = thq._quality,
                    t = this,
                    q = t.quality;
                if(o){
                    q = t.quality = o;
                    thq._quality = null;
                }else{ t.quality = thq._quality = q; }
                t._renderer.setQuality(q);
                return t;
            },
            
            getTime: function(){
                return this._startTime;
            }
        };
    })();
    
    (function(){
        var NS_SVG = "http://www.w3.org/2000/svg",
            NS_XLINK = "http://www.w3.org/1999/xlink",
            NS_XHTML = "http://www.w3.org/1999/xhtml",
            b = Gordon.buttonStates,
            buttonStates = {},
            buttonMask = 0;
        for(var state in b){ buttonStates[b[state]] = state.toLowerCase(); }
        
        Gordon.SvgRenderer = function(width, height, frmSize, quality, scale, bgcolor){
            var t = this,
                n = t.node = t._createElement("svg"),
                frmLeft = frmSize.left,
                frmTop = frmSize.top,
                attrs = {
                    width: width,
                    height: height,
                    viewBox: '' + [frmLeft, frmTop, frmSize.right - frmLeft, frmSize.bottom - frmTop]
                };
            t.width = width;
            t.height = height;
            t.frmSize = frmSize;
            t.quality = quality || Gordon.qualityValues.HIGH;
            t.scale = scale || Gordon.scaleValues.SHOW_ALL;
            t.bgcolor = bgcolor;
            if(scale == Gordon.scaleValues.EXACT_FIT){ attrs.preserveAspectRatio = "none"; }
            t._setAttributes(n, attrs);
            t._defs = n.appendChild(t._createElement("defs"));
            var s = t._stage = n.appendChild(t._createElement('g'));
            t._setAttributes(s, {
                "fill-rule": "evenodd",
                "stroke-linecap": "round",
                "stroke-linejoin": "round"
            });
            t.setQuality(t.quality);
            if(bgcolor){ t.setBgcolor(bgcolor); }
            t._dictionary = {};
            t._fills = {};
            t._set = {};
            t._timeline = [];
            t._displayList = {};
            t._eventTarget = null;
        };
        Gordon.SvgRenderer.prototype = {
            _createElement: function(name){
                return doc.createElementNS(NS_SVG, name);
            },
            
            _setAttributes: function(node, attrs, ns){
                if(node){
                    for(var name in attrs){
                        if(ns){ node.setAttributeNS(ns, name, attrs[name]); }
                        else{ node.setAttribute(name, attrs[name]); }
                    }
                }
                return node;
            },
            
            setQuality: function(quality){
                var q = Gordon.qualityValues,
                    t = this;
                switch(quality){
                    case q.LOW:
                        var attrs = {
                            "shape-rendering": "crispEdges",
                            "image-rendering": "optimizeSpeed",
                            "text-rendering": "optimizeSpeed",
                            "color-rendering": "optimizeSpeed"
                        }
                        break;
                    case q.AUTO_LOW:
                    case q.AUTO_HIGH:
                        var attrs = {
                            "shape-rendering": "auto",
                            "image-rendering": "auto",
                            "text-rendering": "auto",
                            "color-rendering": "auto"
                        }
                        break;
                    case q.MEDIUM:
                        var attrs = {
                            "shape-rendering": "optimizeSpeed",
                            "image-rendering": "optimizeSpeed",
                            "text-rendering": "optimizeLegibility",
                            "color-rendering": "optimizeSpeed"
                        }
                        break;
                    case q.HIGH:
                        var attrs = {
                            "shape-rendering": "geometricPrecision",
                            "image-rendering": "auto",
                            "text-rendering": "geometricPrecision",
                            "color-rendering": "optimizeQuality"
                        }
                        break;
                    case q.BEST:
                        var attrs = {
                            "shape-rendering": "geometricPrecision",
                            "image-rendering": "optimizeQuality",
                            "text-rendering": "geometricPrecision",
                            "color-rendering": "optimizeQuality"
                        }
                        break;
                }
                t._setAttributes(t._stage, attrs);
                t.quality = quality;
                return t;
            },
            
            setBgcolor: function(rgb){
                var t = this;
                if(!t.bgcolor){
                    t.node.style.background = color2string(rgb);
                    t.bgcolor = rgb;
                }
                return t;
            },
            
            define: function(obj){
                var t = this,
                    d = t._dictionary,
                    id = obj.id,
                    item = d[id],
                    type = obj.type,
                    node = null,
                    attrs = {id: type[0] + id};
                if(!item || !item.node){
                    switch(type){
                        case "shape":
                            var segments = obj.segments,
                                fill = obj.fill;
                            if(segments){
                                var node = t._createElement('g'),
                                    frag = doc.createDocumentFragment();
                                for(var i = 0, seg = segments[0]; seg; seg = segments[++i]){
                                    var segNode = frag.appendChild(t._createElement("path"));
                                    t._setAttributes(segNode, {id: 's' + seg.id, d: seg.commands});
                                }
                                node.appendChild(frag);
                            }else{
                                if(fill && "pattern" == fill.type && !fill.repeat){
                                    var node = t._createElement("use");
                                    t._setAttributes(node, {href: "#" + fill.image.id}, NS_XLINK);
                                    attrs.transform = matrix2string(fill.matrix);
                                }else{
                                    var node = t._createElement("path");
                                    attrs.d = obj.commands;
                                }
                            }
                            break;
                        case "image":
                            var node = t._createElement("image"),
                                colorData = obj.colorData,
                                width = obj.width,
                                height = obj.height;
                            if(colorData){
                                var colorTableSize = obj.colorTableSize || 0,
                                    bpp = (obj.withAlpha ? 4 : 3),
                                    cmIdx = colorTableSize * bpp,
                                    data = (new Gordon.Stream(colorData)).unzip(true),
                                    withAlpha = obj.withAlpha,
                                    pxIdx = 0,
                                    canvas = doc.createElement("canvas"),
                                    ctx = canvas.getContext("2d"),
                                    imgData = ctx.getImageData(0, 0, width, height),
                                    pxData = imgData.data,
                                    pad = colorTableSize ? ((width + 3) & ~3) - width : 0
                                canvas.width = width;
                                canvas.height = height;
                                for(var y = 0; y < height; y++){
                                    for(var x = 0; x < width; x++){
                                        var idx = (colorTableSize ? data[cmIdx++] : cmIdx) * bpp,
                                            alpha = withAlpha ? data[cmIdx + 3] : 255;
                                        if(alpha){
                                            pxData[pxIdx] = data[idx];
                                            pxData[pxIdx + 1] = data[idx + 1];
                                            pxData[pxIdx + 2] = data[idx + 2];
                                            pxData[pxIdx + 3] = alpha;
                                        }
                                        pxIdx += 4;
                                    }
                                    cmIdx += pad;
                                }
                                ctx.putImageData(imgData, 0, 0);
                                var uri = canvas.toDataURL();
                            }else{
                                var alphaData = obj.alphaData,
                                    uri = "data:image/jpeg;base64," + btoa(obj.data);
                                if(alphaData){
                                    var img = new Image(),
                                        canvas = doc.createElement("canvas"),
                                        ctx = canvas.getContext("2d"),
                                        len = width * height,
                                        data = (new Gordon.Stream(alphaData)).unzip(true);
                                    img.src = uri;
                                    canvas.width = width;
                                    canvas.height = height;
                                    ctx.drawImage(img, 0, 0);
                                    var imgData = ctx.getImageData(0, 0, width, height),
                                        pxData = imgData.data,
                                        pxIdx = 0;
                                    for(var i = 0; i < len; i++){
                                        pxData[pxIdx + 3] = data[i];
                                        pxIdx += 4;
                                    }
                                    ctx.putImageData(imgData, 0, 0);
                                    uri = canvas.toDataURL();
                                }
                            }
                            t._setAttributes(node, {href: uri}, NS_XLINK);
                            attrs.width = width;
                            attrs.height = height;
                            break;
                        case "font":
                            var info = obj.info;
                            if(info){
                                var node = t._createElement("font"),
                                    faceNode = node.appendChild(t._createElement("font-face")),
                                    advanceTable = info.advanceTable
                                    glyphs = obj.glyphs,
                                    codes = info.codes,
                                    frag = doc.createDocumentFragment(),
                                    kerningTable = info.kerningTable;
                                t._setAttributes(faceNode, {
                                    "font-family": id,
                                    "units-per-em": 20480,
                                    ascent: info.ascent || 20480,
                                    descent: info.ascent || 20480,
                                    "horiz-adv-x": advanceTable ? '' + advanceTable : 20480
                                });
                                for(var i = 0, glyph = glyphs[0]; glyph; glyph = glyphs[++i]){
                                    var cmds = glyph.commands,
                                        code = codes[i];
                                    if(cmds && code){
                                        var glyphNode = frag.appendChild(t._createElement("glyph"));
                                        t._setAttributes(glyphNode, {
                                            unicode: fromCharCode(code),
                                            d: glyph.commands
                                        });
                                    }
                                }
                                if(kerningTable){
                                    for(var i = 0, kern = kerningTable[0]; kern; kern = kerningTable[++i]){
                                        var kernNode = frag.appendChild(t._createElement("hkern"));
                                        t._setAttributes(kernNode, {
                                            g1: kern.code1,
                                            g2: kern.code2,
                                            k: kern.adjustment
                                        });
                                    }
                                }
                                node.appendChild(frag);
                            }
                            break;
                        case "text":
                            var frag = doc.createDocumentFragment(),
                                strings = obj.strings;
                            for(var i = 0, string = strings[0]; string; string = strings[++i]){
                                var txtNode = frag.appendChild(t._createElement("text")),
                                    entries = string.entries,
                                    font = t._dictionary[string.font].object,
                                    info = font.info,
                                    codes = info.codes,
                                    advances = [],
                                    chars = [];
                                    x = string.x,
                                    y = string.y * -1;
                                for(var j = 0, entry = entries[0]; entry; entry = entries[++j]){
                                    var str = fromCharCode(codes[entry.index]);
                                    if(' ' != str || chars.length){
                                        advances.push(x);
                                        chars.push(str);
                                    }
                                    x += entry.advance;
                                }
                                t._setAttributes(txtNode, {
                                    id: 't' + id + '-' + (i + 1),
                                    "font-family": font.id,
                                    "font-size": string.size * 20,
                                    x: advances.join(' '),
                                    y: y
                                });
                                txtNode.appendChild(doc.createTextNode(chars.join('')));
                            }
                            if(strings.length > 1){
                                var node = t._createElement('g');
                                node.appendChild(frag);
                            }else{ var node = frag.firstChild; }
                            break;
                    }
                    if(node){
                        t._setAttributes(node, attrs);
                        t._defs.appendChild(node);
                    }
                    d[id] = {
                        object: obj,
                        node: node
                    }
                }else{ d[id].object = obj; }
                return t;
            },
            
            frame: function(frm){
                var bgcolor = frm.bgcolor,
                    t = this,
                    d = frm.displayList;
                if(bgcolor && !t.bgcolor){
                    t.setBgcolor(bgcolor);
                    t.bgcolor = bgcolor;
                }
                for(depth in d){
                    var character = d[depth];
                    if(character){ t._cast(character); }
                }
                t._timeline.push(frm);
                return t;
            },
            
            _cast: function(character, cxform2){
                var t = this,
                    objId = character.object || t._displayList[character.depth].character.object;
                if(objId){
                    if(character.clipDepth){
                        var cpNode = t._defs.appendChild(t._createElement("clipPath")),
                            useNode = cpNode.appendChild(t._createElement("use")),
                            attrs = {id: 'p' + objId},
                            matrix = character.matrix;
                        t._setAttributes(useNode, {href: '#s' + objId}, NS_XLINK);
                        if(matrix){ attrs.transform = matrix2string(matrix); }
                        t._setAttributes(useNode, attrs);
                    }
                    var cxform1 = character.cxform,
                        cxform = cxform1 && cxform2 ? concatCxform(cxform1, cxform2) : cxform1 || cxform2,
                        characterId = character._id = objectId({
                            object: objId,
                            cxform: cxform
                        });
                    if(!t._set[characterId]){
                        var obj = t._dictionary[objId].object,
                            node = null,
                            type = obj.type,
                            t = this,
                            attrs = {id: 'c' + characterId};
                        switch(type){
                            case "shape":
                                var segments = obj.segments;
                                if(segments){
                                    var node = t._createElement('g'),
                                        frag = doc.createDocumentFragment();
                                    for(var i = 0, seg = segments[0]; seg; seg = segments[++i]){
                                        var useNode = frag.appendChild(t._createElement("use"));
                                        t._setAttributes(useNode, {href: '#s' + objId}, NS_XLINK);
                                        t._setStyle(useNode, obj.fill, obj.line, cxform);
                                    }
                                    node.appendChild(frag);
                                }else{
                                    var node = t._createElement("use");
                                    t._setAttributes(node, {href: '#s' + objId}, NS_XLINK);
                                    t._setStyle(node, obj.fill, obj.line, cxform);
                                }
                                break;
                            case "button":
                                var states1 = obj.states,
                                    states2 = character._states = {},
                                    btnCxform = obj.cxform;
                                for(var state in states1){
                                    var list1 = states1[state],
                                        list2 = states2[state] || (states2[state] = {});
                                    for(var depth in list1){
                                        var stateCharacter = list2[depth] = cloneCharacter(list1[depth]);
                                        t._cast(stateCharacter, cxform1 || btnCxform);
                                    }
                                }
                                break;
                            case "text":
                                var strings = obj.strings,
                                    numStrings = strings.length,
                                    frag = doc.createDocumentFragment(),
                                    matrix = cloneMatrix(obj.matrix);
                                for(var i = 0; i < numStrings; i++){
                                    var useNode = frag.appendChild(t._createElement("use")),
                                        id = objId + (numStrings > 1 ? '-' + (i + 1) : ''),
                                        string = strings[i];
                                    t._setAttributes(useNode, {href: '#t' + id}, NS_XLINK);
                                    t._setStyle(useNode, string.fill, null, cxform);
                                }
                                if(strings.length > 1){
                                    var node = t._createElement('g');
                                    node.appendChild(frag);
                                }else{ var node = frag.firstChild; }
                                matrix.scaleY *= -1;
                                attrs.transform = matrix2string(matrix);
                                break;
                        }
                        if(node){
                            t._setAttributes(node, attrs);
                            t._defs.appendChild(node);
                            t._set[characterId] = {
                                character: character,
                                node: node
                            };
                        }
                    }
                }
                return t;
            },
            
            _setStyle: function(node, fill, line, cxform){
                var t = this,
                    attrs = {};
                if(fill){
                    var type = fill.type;
                    if(fill.type){
                        var fillNode = t._defs.appendChild(t._buildFill(fill, cxform));
                        attrs.fill = "url(#" + fillNode.id + ')';
                    }else{
                        var color = cxform ? transformColor(fill, cxform) : fill,
                            alpha = color.alpha;
                        attrs.fill = color2string(color);
                        if(undefined != alpha && alpha < 1){ attrs["fill-opacity"] = alpha; }
                    }
                }else{ attrs.fill = "none"; }
                if(line){
                    var color = cxform ? transformColor(line.color, cxform) : line.color,
                        alpha = color.alpha;
                    attrs.stroke = color2string(color);
                    attrs["stroke-width"] = max(line.width, 20);
                    if(undefined != alpha && alpha < 1){ attr["stroke-opacity"] = alpha; }
                }
                t._setAttributes(node, attrs);
                return t;
            },
            
            _buildFill: function(fill, cxform){
                var t = this,
                    f = t._fills,
                    id = objectId({
                        fill: fill,
                        cxform: cxform
                    }),
                    node = f[id];
                if(!node){
                    var type = fill.type,
                        attrs = {id: type[0] + id};
                    switch(type){
                        case "linear":
                        case "radial":
                            var node = t._createElement(type + "Gradient"),
                                s = Gordon.spreadModes,
                                i = Gordon.interpolationModes,
                                stops = fill.stops;
                            attrs.gradientUnits = "userSpaceOnUse";
                            attrs.gradientTransform = matrix2string(fill.matrix);
                            if("linear" == type){ 
                                attrs.x1 = -819.2;
                                attrs.x2 = 819.2;
                            }else{
                                attrs.cx = attrs.cy = 0;
                                attrs.r = 819.2;
                            }
                            switch(fill.spread){
                                case s.REFLECT:
                                    attrs.spreadMethod = "reflect";
                                    break;
                                case s.REPEAT:
                                    attrs.spreadMethod = "repeat";
                                    break;
                            }
                            if(fill.interpolation == i.LINEAR_RGB){ attrs["color-interpolation"] = "linearRGB"; }
                            stops.forEach(function(stop){
                                var stopNode = node.appendChild(t._createElement("stop")),
                                    color = cxform ? transformColor(stop.color, cxform) : stop.color;
                                t._setAttributes(stopNode, {
                                    offset: stop.offset,
                                    "stop-color": color2string(color),
                                    "stop-opacity": "alpha" in color ? 1 : color.alpha
                                });
                            });
                            break;
                        case "pattern":
                            var node = t._createElement("pattern"),
                                fillImg = fill.image,
                                width = fillImg.width,
                                height = fillImg.height;
                            if(cxform){
                                var img = new Image(),
                                    origin = doc.getElementById('i' + fillImg.id),
                                    canvas = doc.createElement("canvas"),
                                    ctx = canvas.getContext("2d"),
                                    imgNode = node.appendChild(t._createElement("image"));
                                img.src = origin.getAttribute("href");
                                canvas.width = width;
                                canvas.height = height;
                                ctx.drawImage(img, 0, 0);
                                var imgData = ctx.getImageData(0, 0, width, height),
                                    pxData = imgData.data,
                                    len = pxData.length,
                                    multR = cxform.multR,
                                    multG = cxform.multG,
                                    multB = cxform.multB,
                                    addR = cxform.addR,
                                    addG = cxform.addG,
                                    addB = cxform.addB;
                                for(var i = 0; i < len; i+= 4){
                                    pxData[i] = ~~max(0, min((pxData[i] * multR) + addR, 255));
                                    pxData[i + 1] = ~~max(0, min((pxData[i + 1] * multG) + addG, 255));
                                    pxData[i + 2] = ~~max(0, min((pxData[i + 2] * multB) + addB, 255));
                                }
                                ctx.putImageData(imgData, 0, 0);
                                t._setAttributes(imgNode, {href: canvas.toDataURL()}, NS_XLINK);
                                t._setAttributes(imgNode, {
                                    width: width,
                                    height: height,
                                    opacity: ~~max(0, min(cxform.multA + cxform.addA, 1))
                                });
                            }else{
                                var useNode = node.appendChild(t._createElement("use"));
                                t._setAttributes(useNode, {href: "#i" + fillImg.id}, NS_XLINK);
                            }
                            attrs.patternUnits = "userSpaceOnUse";
                            attrs.patternTransform = matrix2string(fill.matrix);
                            attrs.width = width;
                            attrs.height = height;
                            break;
                    }
                    t._setAttributes(node, attrs);
                    t._fills[id] = node;
                }
                return node;
            },
            
            show: function(frmIdx){
                var t = this,
                    frm = t._timeline[frmIdx],
                    d = frm.displayList;
                for(var depth in d){
                    var character = d[depth];
                    if(character){ t.place(character); }
                    else{ t.remove(depth); }
                }
                return t;
            },
            
            place: function(character){
                var depth = character.depth,
                    t = this,
                    d = t._displayList,
                    replace = d[depth];
                if(replace && !character.object){
                    var id = character._id,
                        node = replace.node,
                        matrix = character.matrix;
                    if(id != replace.character._id){ t._setAttributes(node, {href: "#c" + id}, NS_XLINK); }
                    var matrix = character.matrix;
                    if(matrix && matrix != replace.matrix){ t._setAttributes(node, {transform: matrix2string(matrix)}); }
                }else{
                    if(character.clipDepth){
                        var node = t._createElement('g');
                        t._setAttributes(node, {"clip-path": "url(#p" + character.object + ')'});
                    }else{ var node = t._prepare(character); }
                    if(replace){ t.remove(depth); }
                    var stage = t._stage;
                    if(1 == depth){ stage.insertBefore(node, stage.firstChild); }
                    else{
                        var nextDepth = 0;
                        for(var entry in d){
                            var c = d[entry].character;
                            if(c.clipDepth && depth <= c.clipDepth){ stage = d[entry].node; }
                            if(entry > depth){
                                nextDepth = entry;
                                break;
                            }
                        }
                        if(nextDepth){ stage.insertBefore(node, d[nextDepth].node); }
                        else{ stage.appendChild(node); }
                    }
                }
                d[depth] = {
                    character: character,
                    node: node
                };
                return t;
            },
            
            _prepare: function(character){
                var t = this,
                    obj = t._dictionary[character.object].object,
                    type = obj.type,
                    node = null,
                    matrix = character.matrix;
                switch(type){
                    case "button":
                        var node = t._createElement('g'),
                            states = character._states,
                            btnCxform = obj.cxform,
                            hitNode = null,
                            stateNodes = {},
                            frag = doc.createDocumentFragment(),
                            style = doc.body.style,
                            currState = b.UP,
                            m = Gordon.mouseButtons,
                            isMouseOver = false,
                            action = obj.action,
                            trackAsMenu = obj.trackAsMenu;
                        for(var state in states){
                            var stateFrag = doc.createDocumentFragment(),
                                list = states[state];
                            for(var depth in list){ stateFrag.appendChild(t._prepare(list[depth])); }
                            if(stateFrag.length > 1){
                                var stateNode = t._createElement('g');
                                stateNode.appendChild(stateFrag);
                            }else{ var stateNode = stateFrag.firstChild; }
                            if(state == b.HIT){
                                t._setAttributes(stateNode, {opacity: 0});
                                hitNode = stateNode;
                            }else{
                                t._setAttributes(stateNode, {visibility: state == b.UP ? "visible" : "hidden"});
                                stateNodes[state] = frag.appendChild(stateNode);
                            }
                        }
                        node.appendChild(frag);
                        node.appendChild(hitNode);
                        
                        function setState(state){
                            if(state == b.UP){ style.cursor = setState._cursor || "default"; }
                            else{
                                setState._cursor = style.cursor;
                                style.cursor = "pointer";
                            }
                            t._setAttributes(stateNodes[currState], {visibility: "hidden"});
                            t._setAttributes(stateNodes[state], {visibility: "visible"});
                            currState = state;
                        };
                        
                        hitNode.onmouseover = function(){
                            if(!(buttonMask & m.LEFT)){ setState(b.OVER); }
                            else if(this == t.eventTarget){ setState(b.DOWN); }
                            return false;
                        }
                        
                        hitNode.onmousedown = function(){
                            t.eventTarget = this;
                            setState(b.DOWN);
                            var handle = doc.addEventListener("mouseup", function(){
                                setState(b.UP);
                                doc.removeEventListener("mouseup", handle, true);
                                t.eventTarget = null;
                            }, true);
                            return false;
                        }
                        
                        hitNode.onmouseup = function(){
                            setState(b.OVER);
                            if(this == t.eventTarget){
                                if(action){ action(); }
                                t.eventTarget = null;
                            }
                            return false;
                        }
                        
                        hitNode.onmouseout = function(){
                            if(this == t.eventTarget){
                                if(trackAsMenu){
                                    t.eventTarget = null;
                                    setState(b.UP);
                                }else{ setState(b.OVER); }
                            }
                            else{ setState(b.UP); }
                            return false;
                        }
                        break;
                    default:
                        var node = t._createElement("use");
                        t._setAttributes(node, {href: "#c" + character._id}, NS_XLINK);
                }
                if(matrix){ t._setAttributes(node, {transform: matrix2string(matrix)}); }
                return node;
            },
            
            remove: function(depth){
                var d = this._displayList,
                    item = d[depth],
                    node = item.node,
                    parentNode = node.parentNode;
                if(item.character.clipDepth){
                    var childNodes = node.childNodes;
                    for(var c in childNodes){ parentNode.insertBefore(childNodes[c], node); }
                }
                parentNode.removeChild(node);
                delete d[depth];
                return this;
            }
        };
        
        var REGEXP_IS_COLOR = /^([\da-f]{1,2}){3}$/i;
        
        function color2string(color){
            if("string" == typeof color){ return REGEXP_IS_COLOR.test(color) ? color : null; }
            return "rgb(" + [color.red, color.green, color.blue] + ')';
        }
        
        function matrix2string(matrix){
            return "matrix(" + [
                matrix.scaleX, matrix.skewX,
                matrix.skewY, matrix.scaleY,
                matrix.moveX, matrix.moveY
            ] + ')';
        }
        
        function transformColor(color, cxform){
            return {
                red: ~~max(0, min((color.red * cxform.multR) + cxform.addR, 255)),
                green: ~~max(0, min((color.green * cxform.multG) + cxform.addG, 255)),
                blue: ~~max(0, min((color.blue * cxform.multB) + cxform.addB, 255)),
                alpha: ~~max(0, min((color.alpha * cxform.multA) + cxform.addA, 255))
            }
        }
        
        function objectId(obj){
            var memo = objectId._memo || (objectId._memo = {}),
                nextId = (objectId._nextId || (objectId._nextId = 1)),
                key = object2key(obj),
                origId = memo[key];
            if(!origId){ memo[key] = nextId; }
            return origId || objectId._nextId++;
        }
        
        function object2key(obj){
            var a = 1,
                b = 0;
            for(var prop in obj){
                var val = obj[prop];
                if("object" == typeof val){ a += object2key(val); }
                else{
                    var buff = '' + val;
                    for(var j = 0; buff[j]; j++){
                        a = (a + buff.charCodeAt(j)) % 65521;
                        b = (b + a) % 65521;
                    }
                }
            }
            return (b << 16) | a;
        }
        
        function concatCxform(cxform1, cxform2){
            return{
                multR: cxform1.multR * cxform2.multR, multG: cxform1.multG * cxform2.multG,
                multB: cxform1.multB * cxform2.multB, multA: cxform1.multA * cxform2.multA,
                addR: cxform1.addR + cxform2.addR, addG: cxform1.addG + cxform2.addG,
                addB: cxform1.addB + cxform2.addB, addA: cxform1.addA + cxform2.addA
            }
        }
        
        function cloneCharacter(character){
            return {
                object: character.object,
                depth: character.depth,
                matrix: character.matrix,
                cxform: character.cxform
            };
        }
        
        function cloneMatrix(matrix){
            return {
                scaleX: matrix.scaleX, scaleY: matrix.scaleY,
                skewX: matrix.skewX, skewY: matrix.skewY,
                moveX: matrix.moveX, moveY: matrix.moveY
            };
        }
        
        if(doc){
            doc.addEventListener("mousedown", function(e){
                buttonMask |= 0x01 << e.button;
            }, true);
            doc.addEventListener("mouseup", function(e){
                buttonMask ^= 0x01 << e.button;
            }, true);
        }
    })();
    
    win.Gordon = Gordon;
})(self);
