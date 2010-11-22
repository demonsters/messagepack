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


	final public class MessagePack
	{



		/**
		 * Encodes a object into a MessagePack ByteArray.
		 *
		 * @param o The object to create a MessagePack ByteArray for
		 * @return the MessagePack ByteArray representing o
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function encode( o:* ):ByteArray
		{
			return new MessagePackEncode( o ).getByteArray();
		}

		/**
		 * Decodes a MessagePack ByteArray into a native object.
		 *
		 * @param bytes The MessagePack ByteArray representing the object
		 * @return A native object as specified by bytes
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function decode(bytes:ByteArray):*
		{
			return new MessagePackDecode(bytes).getObject();
		}

		/**
		 * Displays a ByteArray into a HEX value String, can be usefull for debugging.
		 *
		 * @param bytes The ByteArray representing the object
		 * @return A HEX String as specified by bytes
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function rawBytesToHexString(bytes:ByteArray):String{
			//To show hex value's of a byte array (doesnt add 0x)

					var s:String=""; 
					while (bytes.position < bytes.length)
					{   
						var n:String = bytes.readUnsignedByte().toString(16); 
						if(n.length<2){ 
							 n="0"+n; 
						} 
						 s+=n; 
					} 
					return "HEX: " + s;

		}
	}
}
