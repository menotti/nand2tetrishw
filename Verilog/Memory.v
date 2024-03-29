// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/Memory.hdl

/**
 * The complete address space of the computer's memory,
 * including RAM and memory mapped I/O. 
 * The chip facilitates read and write operations, as follows:
 *     Read:  out(t) = Memory[address(t)](t)
 *     Write: If load(t-1) then Memory[address(t-1)](t) = in(t-1)
 * In words: the chip always outputs the value stored at the memory 
 * location specified by address. If load=1, the in value is loaded 
 * into the memory location specified by address. This value becomes 
 * available through the out output in the next time step.
 * Address space rules:
 * Only the upper 16K+8K+1 words of the Memory chip are used. 
 * Access to address>0x6000 is invalid. Access to any address in 
 * the range 0x4000-0x5FFF results in accessing the screen memory 
 * map. Access to address 0x6000 results in accessing the keyboard 
 * memory map. The behavior in these addresses is described in the 
 * Screen and Keyboard chip specifications given in the book.
 */

module Memory 
    IN [16]in, load, address[15];
    OUT [16]out;

    PARTS:
    DMux4Way (in=load, sel=address[13..14], a=load0, b=load1, c=loadScreen);
    Or       (a=load0, b=load1, out=loadRAM);
    RAM16K   (in=in, load=loadRAM, address=address[0..13], out=ramOut);
    Screen   (in=in, load=loadScreen, address=address[0..12], out=screenOut);

    // check if keyboard address - 0x6000 = 110 0000 0000 0000
    And    (a=address[13], b=address[14], out=and1314);
    Or8Way (in=address[0..7], out=or0to7);
    Or8Way (in=address[5..12], out=or5to12);
    Or     (a=or0to7, b=or5to12, out=or0to12);
    Not    (in=or0to12, out=zero0to12);
    And    (a=zero0to12, b=and1314, out=keyAddress);

    // if keyboard address, output keyboard contents
    Keyboard  (out=key);
    Mux16     (a=false, b=key, sel=keyAddress, out=keyOut);
    Mux4Way16 (a=ramOut, b=ramOut, c=screenOut, d=keyOut, sel=address[13..14], out=out);
}


// Alternate implementation for keyboard decoding.
/*
    // check if keyboard address - 0x6000 = 110 0000 0000 0000
    // The output Mux4Way16 selects the range 0x6000 - 0x7FFF (the 1's). 
    // Decode xx0 0000 0000 0000 so that only 0x6000 responds within
    // this range.
    Or8Way (in=address[0..7], out=or0to7);
    Or8Way (in[0]=or0to7, in[1..7]=address[6..12], out=or0to12);
    Not (in=or0to12, out=keyAddress);

    // if keyboard address, output keyboard contents
    Keyboard (out=key);
    Mux16 (a=false, b=key, sel=keyAddress, out=keyOut);

    Mux4Way16 (a=ramOut, b=ramOut, c=screenOut, d=keyOut, sel=address[13..14], out=out);
*/


// Alternate implementation.
//
// The book says "Access to any address>24576 (0x6000) is invalid."  It can be
// argued that any access to an invalid address may return a don't-care value.
// The current keyboard value is as good a don't-care as any, so there is no
// need to decode the specific address.
//
// Some argue that this is poor engineering practice.
// Fully decoding I/O addresses should be encouraged.
/*
    PARTS:
    DMux4Way (in=load, sel=address[13..14], a=load0, b=load1, c=loadScreen);
    Or (a=load0, b=load1, out=loadRAM);
    RAM16K (in=in, load=loadRAM, address=address[0..13], out=ramOut);
    Screen (in=in, load=loadScreen, address=address[0..12], out=screenOut);
    Keyboard (out=keyOut);
    Mux4Way16 (a=ramOut, b=ramOut, c=screenOut, d=keyOut, sel=address[13..14], out=out);
*/
