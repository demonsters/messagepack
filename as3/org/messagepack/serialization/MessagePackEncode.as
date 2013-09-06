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
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	final internal class MessagePackEncode
	{

		private static const LONG_MIN_VALUE:Number = -9223372036854775808;
		private static const LONG_MAX_VALUE:Number = 9223372036854775807;

		private static const FLOAT_MIN_VALUE:Number = -1.40129846432481707e+45;
		private static const FLOAT_MAX_VALUE:Number = 1.40129846432481707e+45;

		private static const DOUBLE_FLOAT_MIN_VALUE:Number = -4.94065645841246544e+324;
		private static const DOUBLE_FLOAT_MAX_VALUE:Number = 4.94065645841246544e+324;

		
		public static function encode(input:*):ByteArray
		{
			var output:ByteArray = new ByteArray();
            if(!input){
                packNull(output);
                return output;
            }
			var name:String = getQualifiedClassName(input);
			var type:Class = getDefinitionByName(name) as Class;

			switch(type) {
				case int:
					packInt(input, output);	
					break;
				case Boolean:
					packBoolean(input, output);
					break;
				case null:
					packNull(output);
					break;
				case Number:
					packNumber(input, output);
					break;
				case String:
					packString(input, output);
					break;
				case XML:
					packString(String(input), output);
					break;
				case ByteArray:
					packByteArray(input, output);
					break;
				case Array:
					packArray(input, output);
					break;
                default:
                    packObject(input, output)
					break;
			}
			
			return output;
		}


        private static function packObject(obj:Object, output:ByteArray):void
        {
            var count:int = 0;
            for (var i:* in obj){
               count++;
                //trace(i+" :: "+obj[i]);
            }
//            trace("the count ", count);
            if (count < 16) {
                var arrShort:int = 0x80 | count;
                output.writeByte(arrShort) ;
            } else if (count < 65536) {
                output.writeByte(0xde);
                output.writeShort(count);
            } else {
                output.writeByte(0xdf);
                output.writeUnsignedInt(count);
            }
            packObjectContent(obj, output);
        }


        private static function packObjectContent(obj:Object, output:ByteArray):void
        {
            for (var i:* in obj) {
                var name:String = getQualifiedClassName(obj[i]);
//                trace(name);
                var type:Class = getDefinitionByName(name) as Class;
//                trace(type);
                packString(String(i), output);
                switch(type) {
                    case int:
                    case uint:
                        packInt(obj[i], output);
                        break;
                    case Number:
                        packNumber(obj[i], output);
                        break;
                    case Boolean:
                        packBoolean(obj[i], output);
                        break;
                    case null:
                        packNull(output);
                        break;
                    case XML:
                        packString(String(obj[i]), output);
                        break;
                    case String:
                        packString(obj[i], output);
                        break;
                    case ByteArray:
                        packByteArray(obj[i], output);
                        break;
                    case Array:
                        packArray(obj[i], output);
                        break;
                    default:
                        packObject(obj[i], output);
                        break;
                }
            }
        }
		
		private static function packArray(array:Array, output:ByteArray):void
		{
			if (array.length < 16) {
				var arrShort:int = 0x90 | array.length;
				output.writeByte(arrShort) ;
			}
			else if (array.length < 65536) {
				output.writeByte(0xdc);
				output.writeShort(array.length);
			} else {
				output.writeByte(0xdd);
				output.writeUnsignedInt(array.length);
			}
			packArrayContent(array, output);
		}

		
		private static function packArrayContent(array:Array, output:ByteArray):void
		{
			for (var i:int = 0;i < array.length;i++) {
				var name:String = getQualifiedClassName(array[i]);
				var type:Class = getDefinitionByName(name) as Class;
				
				switch(type) {
					case int:
					case uint:
						packInt(array[i], output);	
						break;
					case Boolean:
						packBoolean(array[i], output);
						break;
					case null:
						packNull(output);
						break;
					case Number:
						packNumber(array[i], output);
						break;
					case XML:
						packString(String(array[i]), output);
						break;
					case String:
						packString(array[i], output);
						break;
					case ByteArray:
						packByteArray(array[i], output);
						break;
					case Array:
						packArray(array[i], output);
						break;
                    default:
                        packObject(array[i], output);
                        break;
				}
			}
		}

		
		private static function packInt(value:int, output:ByteArray):void
		{
			if(value < -(1 << 5)) {
				if(value < -(1 << 15)) {
					// signed 32
					output.writeByte(0xd2);
					output.writeInt(value);
				} else if(value < -(1 << 7)) {
					// signed 16
					output.writeByte(0xd1);
					output.writeShort(value);
				} else {
					// signed 8
					output.writeByte(0xd0);
					output.writeByte(value);
				}
			} else if(value < (1 << 7)) {
				// fixnum
				output.writeByte(value);
			} else {
				if(value < (1 << 8)) {
					// unsigned 8
					output.writeByte(0xcc);
					output.writeByte(value);
				} else if(value < (1 << 16)) {
					// unsigned 16
					output.writeByte(0xcd);
					output.writeShort(value);
				} else {
					// unsigned 32
					output.writeByte(0xce);
					output.writeUnsignedInt(value);
				}
			}
		}

		
		private static function packNumber(value:Number, output:ByteArray):void
		{
			var roundCheck:Number = value % 1;
			if (value < int.MAX_VALUE && value > int.MIN_VALUE && roundCheck == 0) {
				packInt(value, output);	
			} else {
				
				if (value > LONG_MIN_VALUE && value < LONG_MAX_VALUE) {
					packFloat(value, output);
				}else if(value > FLOAT_MIN_VALUE && value < FLOAT_MAX_VALUE) {
					packFloat(value, output);
				}else if(value > DOUBLE_FLOAT_MIN_VALUE && value < DOUBLE_FLOAT_MAX_VALUE) {
					packDouble(value, output);
				}
			}
		}

		
		private static function packFloat(value:Number, output:ByteArray):void
		{
			output.writeByte(0xca);
			output.writeFloat(value);
		}

		
		private static function packDouble(value:Number, output:ByteArray):void
		{
			output.writeByte(0xcb);
			output.writeDouble(value);
		}

		
		private static function packBoolean(value:Boolean, output:ByteArray):void
		{
			if (value) {
				output.writeByte(0xc3);
			} else {
				output.writeByte(0xc2);
			}
		}

		
		private static function packNull(output:ByteArray):void
		{
			output.writeByte(0xc0);
		}

		
		private static function packRaw(length:int, output:ByteArray):void
		{
			if(length < 32) {
				var value:int = 0xa0 | length;
				output.writeByte(value);
			} else if(length < 65536) {
				output.writeByte(0xda);
				output.writeShort(length);
			} else {
				output.writeByte(0xdb);
				output.writeInt(length);
			}
		}

		
		private static function packRawBody(value:ByteArray, output:ByteArray):void
		{
			output.writeBytes(value);
		}

		
		private static function packString(value:String, output:ByteArray):void
		{
			var byteString:ByteArray = new ByteArray();
			byteString.writeUTFBytes(value);
			packRaw(byteString.length, output);
			packRawBody(byteString, output);
		}

		
		private static function packByteArray(value:ByteArray, output:ByteArray):void
		{
			packRaw(value.length, output);
			packRawBody(value, output);
		}
	}
}
