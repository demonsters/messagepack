/**
 *
 * This is a AS3 Port of the MessagePack object serialization library
 *
 * MessagePack is a binary-based efficient object serialization library.
 * It enables to exchange structured objects between many languages like JSON.
 * But unlike JSON, it is very fast and small.
 *
 * For more information about MessagePack object serialization, visit: http://msgpack.org/
 *
 * @author	Joost Harts
 * @company De Monsters
 * @link 	http://www.deMonsters.com
 * @version 0.1
 *
 *
 * Copyright 2010, De Monsters
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package org.messagepack.serialization
{
	import flash.utils.ByteArray;

	final internal class MessagePackDecode
	{


		/**
		 * Constructs a new MessagePackDecoder to parse a JSON string
		 * into a native object.
		 *
		 * @param input / The MessagePAck ByteArray to be converted
		 *		  into a native object
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function decode(input:ByteArray):*
		{
			// Reset position
			input.position = 0;

			// Return object
			var object:Object;

			// Total amount of bytes to check with
			var byteLength:int = input.length;

			while (input.position < byteLength) {
				// The byte identifier
				var byteType:int = input.readUnsignedByte();

				if (byteType > 0x00 && byteType < 0x7f) {
					// Positive FixNum
					var fixNumPos:int = byteType;
					object = fixNumPos;
				}
				else if (byteType > 0xe0 && byteType < 0xff) {
					// Negative FixNum
					var fixNumNeg:int = byteType;
					object = fixNumNeg;
				}
				else if (byteType == 0xc2) {
					// false
					var fal:Boolean = false;
					object = fal;
				}
				else if(byteType == 0xc3) {
					// true
					var tru:Boolean = true;
					object = tru;
				}
				else if (byteType == 0xca) {
					// float
					var float:Number = input.readFloat();
					object = float;
				}
				else if (byteType == 0xcb) {
					//double float
					var doubleFloat:Number = input.readDouble();
					object = doubleFloat;
				}
				else if (byteType == 0xcc) {
					// uint 8
					var uint8:uint = input.readByte();
					object = uint8;
				}
				else if (byteType == 0xcd) {
					//uint 16
					var uint16:uint = input.readShort();
					object = uint16;
				}
				else if (byteType == 0xce) {
					// uint 32
					var uint32:uint = input.readUnsignedInt();
					object = uint32;
				}
				else if (byteType == 0xcf) {
					// uint 64
				}
				else if (byteType == 0xd0) {
					// int 8
					var int8:int = input.readByte();
					object = int8;
				}
				else if (byteType == 0xd1) {
					// int 16
					var int16:int = input.readShort();
					object = int16;
				}
				else if (byteType == 0xd2) {
					//int 32
					var int32:int = input.readInt();
					object = int32;
				}
				else if (byteType == 0xda) {
					// raw 16
					var raw16Arr:ByteArray = new ByteArray();
					var raw16Length:Number = input.readShort();
					input.readBytes(raw16Arr, 0, raw16Length);
					var raw16Str:String = raw16Arr.readUTFBytes(raw16Arr.length);
					object = raw16Str;
				}
				else if (byteType == 0xdb) {
					// raw 32
					var raw32Arr:ByteArray = new ByteArray();
					var raw32Length:Number = input.readInt();
					input.readBytes(raw16Arr, 0, raw32Length);
					var raw32Str:String = raw16Arr.readUTFBytes(raw32Arr.length);
					object = raw32Str;
				}
                else if (byteType == 0xde) {
                    //map 16
                    //trace("MP ", " map 16");
                    var map16:uint = input.readShort();
                    object = decodeMap(input, map16);
                }
                else if (byteType == 0xdf) {
                    //map 32
                    //trace("MP ", " map 32");
                    var map32:uint = input.readShort();
                    object = decodeMap(input, map32);
                }
				else if (byteType == 0xdc) {
					// array 16
					var arr16:Number = input.readShort();
					object = decodeArray(input, arr16);
				}
				else if (byteType == 0xdd) {
					// array 32
					var arr32:Number = input.readUnsignedInt();
					object = decodeArray(input, arr32);
				}
				else if (byteType > 0xa0 && byteType < 0xbf) {
					// FixRaw
					var fixRawArr:ByteArray = new ByteArray();
					input.readBytes(fixRawArr, 0, byteType ^ 0xa0);
					var fixRawStr:String = fixRawArr.readUTFBytes(fixRawArr.length);
					object = fixRawStr;
				}
				else if (byteType >= 0x90 && byteType <= 0x9f) {
					// FixArray
					var fixArray:Number = byteType;
					object = decodeArray(input, fixArray);
				}
                else if (byteType >= 0x80 && byteType <= 0x8f) {
                    // FixMap
                    //trace("MP ", " fixmap");
                    var fixMap:int = byteType - 0x80;
                    object = decodeMap(input, fixMap);
                }
			}

			return object;
		}


		/**
		 * Decodes Array's in the ByteArray
		 */
		private static function decodeArray(input:ByteArray, length:int):Array
		{
			// Creates the array
			var array:Array = new Array();

			// Integer to keep count of the array length
			// so it knows when to end the array object
			var objCount:int = 0;

			// Total amount of bytes to check with
			var byteLength:int = input.length;

			while (input.position < byteLength && objCount < length) {
				// The byte identifier
				var byteType:int = input.readUnsignedByte();

				if (byteType > 0x00 && byteType < 0x7f) {
					// Positive FixNum
					var fixNumPos:int = byteType;
					array.push(fixNumPos);
					objCount++;
				}
				else if (byteType > 0xe0 && byteType < 0xff) {
					// Negative FixNum
					var fixNumNeg:int = byteType;
					array.push(fixNumNeg);
					objCount++;
				}
				else if (byteType == 0xc2) {
					// false
					var fal:Boolean = false;
					array.push(fal);
					objCount++;
				}
				else if(byteType == 0xc3) {
					// true
					var tru:Boolean = true;
					array.push(tru);
					objCount++;
				}
				else if (byteType == 0xca) {
					// float
					var float:Number = input.readFloat();
					array.push(float);
					objCount++;
				}
				else if (byteType == 0xcb) {
					//double float
					var doubleFloat:Number = input.readDouble();
					array.push(doubleFloat);
					objCount++;
				}
				else if (byteType == 0xcc) {
					// uint 8
					var uint8:uint = input.readByte();
					array.push(uint8);
					objCount++;
				}
				else if (byteType == 0xcd) {
					//uint 16
					var uint16:uint = input.readShort();
					array.push(uint16);
					objCount++;
				}
				else if (byteType == 0xce) {
					// uint 32
					var uint32:uint = input.readUnsignedInt();
					array.push(uint32);
					objCount++;
				}
				else if (byteType == 0xcf) {
					// uint 64
				}
				else if (byteType == 0xd0) {
					// int 8
					var int8:int = input.readByte();
					array.push(int8);
					objCount++;
				}
				else if (byteType == 0xd1) {
					// int 16
					var int16:int = input.readShort();
					array.push(int16);
					objCount++;
				}
				else if (byteType == 0xd2) {
					//int 32
					var int32:int = input.readInt();
					array.push(int32);
					objCount++;
				}
				else if (byteType == 0xda) {
					// raw 16
					var raw16Arr:ByteArray = new ByteArray();
					var raw16Length:Number = input.readShort();
					input.readBytes(raw16Arr, 0, raw16Length);
					var raw16Str:String = raw16Arr.readUTFBytes(raw16Arr.length);
					array.push(raw16Str);
					objCount++;
				}
				else if (byteType == 0xdb) {
					// raw 32
					var raw32Arr:ByteArray = new ByteArray();
					var raw32Length:Number = input.readInt();
					input.readBytes(raw16Arr, 0, raw32Length);
					var raw32Str:String = raw16Arr.readUTFBytes(raw32Arr.length);
					array.push(raw32Str);
					objCount++;
				}
                else if (byteType == 0xde) {
                    //map 16
//                    trace("MP ", " map 16");
                    var map16:uint = input.readShort();
                    array.push(decodeMap(input, map16));
                    objCount++;
                }
                else if (byteType == 0xdf) {
                    //map 32
//                    trace("MP ", " map 32");
                    var map32:uint = input.readShort();
                    array.push(decodeMap(input, map32));
                    objCount++;
                }
				else if (byteType == 0xdc) {
					// array 16
					var arr16:Number = input.readShort();
					array.push(decodeArray(input, arr16));
					objCount++;
				}
				else if (byteType == 0xdd) {
					// array 32
					var arr32:Number = input.readUnsignedInt();
					array.push(decodeArray(input, arr32));
					objCount++;
				}
				else if (byteType > 0xa0 && byteType < 0xbf) {
					// FixRaw
					var fixRawArr:ByteArray = new ByteArray();
					input.readBytes(fixRawArr, 0, byteType ^ 0xa0);
					var fixRawStr:String = fixRawArr.readUTFBytes(fixRawArr.length);
					array.push(fixRawStr);
					objCount++;
				}
				else if (byteType >= 0x90 && byteType <= 0x9f) {
					// FixArray
					var fixArray:Number = byteType;
					array.push(decodeArray(input, fixArray));
					objCount++;
				}
                else if (byteType >= 0x80 && byteType <= 0x8f) {
                    // FixMap

                    var fixMap:int = byteType - 0x80;
//                    trace("MP ", " Fixmap ",fixMap);
                    array.push(decodeMap(input, fixMap));
                    objCount++;
                }
			}
			return array;
		}

        /**
         * Decodes Map's in the ByteArray
         */
        private static function decodeMap(input:ByteArray, length:int):Object
        {
//            trace("the map length ", length);
            // Creates the map
            var map:Object = new Object();

            // Integer to keep count of the map length
            // so it knows when to end the map object
            var objCount:int = 0;

            // Total amount of bytes to check with
            var byteLength:int = input.length;
            while (input.position < byteLength && objCount < length) {
                // The byte identifier
                var labelType:int = input.readUnsignedByte();
                var label:String;
                if (labelType > 0xa0 && labelType < 0xbf) {
                    // FixRaw
                    var fixRawArrlabel:ByteArray = new ByteArray();
                    input.readBytes(fixRawArrlabel, 0, labelType ^ 0xa0);
                    var fixRawStrlabel:String = fixRawArrlabel.readUTFBytes(fixRawArrlabel.length);
                    label = fixRawStrlabel;
                    objCount++;
                }else if (labelType == 0xda) {
                    // raw 16
                    var raw16Arrlabel:ByteArray = new ByteArray();
                    var raw16Lengthlabel:Number = input.readShort();
                    input.readBytes(raw16Arrlabel, 0, raw16Lengthlabel);
                    var raw16Strlabel:String = raw16Arrlabel.readUTFBytes(raw16Arrlabel.length);
                    label = raw16Strlabel;
                    objCount++;
                }
                else if (labelType == 0xdb) {
                    // raw 32
                    var raw32Arrlabel:ByteArray = new ByteArray();
                    var raw32Lengthlabel:Number = input.readInt();
                    input.readBytes(raw32Arrlabel, 0, raw32Lengthlabel);
                    var raw32Strlabel:String = raw32Arrlabel.readUTFBytes(raw32Arrlabel.length);
                    label = raw32Strlabel;
                    objCount++;
                }
//                trace("the label ", label);

                var byteType:int = input.readUnsignedByte();

                if (byteType >= 0x00 && byteType < 0x7f) {
                    // Positive FixNum
                    var fixNumPos:int = byteType;
                    map[label] = fixNumPos;
                  //  objCount++;
//                    trace("MPM ", " pos fixnum");
                }
                else if (byteType >= 0xe0 && byteType < 0xff) {
                    // Negative FixNum
                    var fixNumNeg:int = byteType;
                    map[label] = fixNumNeg;
                 //   objCount++;
//                    trace("MPM ", " neg fixnum");
                }
                else if (byteType == 0xc2) {
                    // false
                    var fal:Boolean = false;
                    map[label] = fal;
                 //   objCount++;
//                    trace("MPM ", " false");
                }
                else if (byteType == 0xc3) {
                    // true
                    var tru:Boolean = true;
                    map[label] = tru;
                  //  objCount++;
//                    trace("MPM ", " true");
                }
                else if (byteType == 0xca) {
                    // float
                    var float:Number = input.readFloat();
                    map[label] = float;
                  //  objCount++;
//                    trace("MPM ", " float");
                }
                else if (byteType == 0xcb) {
                    //double float
                    var doubleFloat:Number = input.readDouble();
                    map[label] = doubleFloat;
                  //  objCount++;
//                    trace("MPM ", " double float");
                }
                else if (byteType == 0xcc) {
                    // uint 8
                    var uint8:uint = input.readUnsignedByte();
                    map[label] = uint8;
                   // objCount++;
//                    trace("MPM ", " uint 8");
                }
                else if (byteType == 0xcd) {
                    //uint 16
                    var uint16:uint = input.readShort();
                    map[label] = uint16;
                   // objCount++;
//                    trace("MPM ", " uint 16");
                }
                else if (byteType == 0xce) {
                    // uint 32
                    var uint32:uint = input.readUnsignedInt();
                    map[label] = uint32;
                 //   objCount++;
//                    trace("MPM ", " uint 32");
                }
                else if (byteType == 0xcf) {
                    // uint 64
                    var uint64:Number = input.readUnsignedByte() * 0x1000000 + (input.readUnsignedByte() << 16) +
                            (input.readUnsignedByte() <<  8) + input.readUnsignedByte();
                    uint64 = uint64 * 0x100000000 +
                            input.readUnsignedByte() * 0x1000000 + (input.readUnsignedByte() << 16) +
                            (input.readUnsignedByte() <<  8) + input.readUnsignedByte();
                    map[label] = uint64;
//                    trace("MPM ", " uint 64");
                }
                else if (byteType == 0xd0) {
                    // int 8
                    var int8:int = input.readByte();
                    map[label] = int8;
                 //   objCount++;
//                    trace("MPM ", " int 8");
                }
                else if (byteType == 0xd1) {
                    // int 16
                    var int16:int = input.readShort();
                    map[label] = int16;
                  //  objCount++;
//                    trace("MPM ", " int 16");
                }
                else if (byteType == 0xd2) {
                    //int 32
                    var int32:int = input.readInt();
                    map[label] = int32;
                  //  objCount++;
//                    trace("MPM ", " int 32");
                }
                else if (byteType == 0xda) {
                    // raw 16
                    var raw16Arr:ByteArray = new ByteArray();
                    var raw16Length:Number = input.readShort();
                    input.readBytes(raw16Arr, 0, raw16Length);
                    var raw16Str:String = raw16Arr.readUTFBytes(raw16Arr.length);
                    map[label] = raw16Str;
                 //   objCount++;
//                    trace("MPM ", " raw 16");
                }
                else if (byteType == 0xdb) {
                    // raw 32
                    var raw32Arr:ByteArray = new ByteArray();
                    var raw32Length:Number = input.readInt();
                    input.readBytes(raw16Arr, 0, raw32Length);
                    var raw32Str:String = raw16Arr.readUTFBytes(raw32Arr.length);
                    map[label] = raw32Str;
                  //  objCount++;
//                    trace("MPM ", " raw 32");
                }
                else if (byteType == 0xde) {
                    //map 16
                    var map16:uint = input.readShort();
                    map[label] = decodeMap(input, map16);
//                    trace("MPM ", " map 16");
                }
                else if (byteType == 0xdf) {
                    //map 32
                    var map32:uint = input.readShort();
                    map[label] = decodeMap(input, map32);
//                    trace("MPM ", " map 32");
                }
                else if (byteType == 0xdc) {
                    // array 16
                    var arr16:Number = input.readShort();
                    map[label] = decodeArray(input, arr16);
                  //  objCount++;
//                    trace("MPM ", " array 16");
                }
                else if (byteType == 0xdd) {
                    // array 32
                    var arr32:Number = input.readUnsignedInt();
                    map[label] = decodeArray(input, arr32);
                //    objCount++;
//                    trace("MPM ", " array 32");
                }
                else if (byteType > 0xa0 && byteType < 0xbf) {
                    // FixRaw
                    var fixRawArr:ByteArray = new ByteArray();
                    input.readBytes(fixRawArr, 0, byteType ^ 0xa0);
                    var fixRawStr:String = fixRawArr.readUTFBytes(fixRawArr.length);
                    map[label] = fixRawStr;
                 //   objCount++;
//                    trace("MPM ", " fix raw");
                }
                else if (byteType >= 0x90 && byteType <= 0x9f) {
                    // FixArray
                    var fixArray:Number = byteType - 0x90;
                    map[label] = decodeArray(input, fixArray);
                 //   objCount++;
//                    trace("MPM ", " fix array");
                }
                else if (byteType >= 0x80 && byteType <= 0x8f) {
                    // FixMap
                    var fixMap:int = byteType - 0x80;
                    map[label] = decodeMap(input, fixMap);
//                    trace("MPM ", " fix map");
                }
            }
            return map;
        }
	}
}
