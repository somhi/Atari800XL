#include "joystick.h"

#include "regs.h"

//#include <stdio.h>
//#include <printf.h>
//extern int debug_pos;

#ifdef USB
#include "usb.h"
#endif

#ifdef USB
extern struct usb_host usb_porta;
#endif
#ifdef USB2
extern struct usb_host usb_portb;
#endif

unsigned char pot0;
unsigned char pot1;
unsigned char pot2;
unsigned char pot3;
void joystick_poll(struct joystick_status * status)
{
	status->x_ = 0;
	status->y_ = 0;
	status->fire_ = 0;
	status->escape_ = 0;
	status->keyPressed_ = 0;

#ifdef USB
	usb_poll(&usb_porta);
#endif
#ifdef USB2
	usb_poll(&usb_portb);
#endif

	int controls = get_controls();

	int read = 0;
	if (0==*atari_allpot)
	{
		pot0 = *atari_pot0;
		pot1 = *atari_pot1;
		pot2 = *atari_pot2;
		pot3 = *atari_pot3;
		*atari_potgo = 0xff;
		read = 1;
	}

	unsigned char kbcode = *atari_kbcode;
	kbcode &= 0x1e;

	unsigned char key_held = *atari_skctl;
	if ((key_held&0x4) != 0)
	{
		kbcode = 0x0;
	}

	//debug_pos = 400;
	//printf("%02x %02x %02x %02x\n",pot0,pot1,*atari_allpot,read);

	status->y_ = (0x8==(kbcode&0x18)) -((unsigned int)(0x18==(kbcode&0x18)));
	status->x_ = (0x2==(kbcode&0x6)) -((unsigned int)(0x6==(kbcode&0x6)));

	if (pot0>170) status->x_ =1;
	if (pot0<60) status->x_ =-1;
	if (pot1>170) status->y_ =1;
	if (pot1<60) status->y_ =-1;
	if (pot2>170) status->x_ =1;
	if (pot2<60) status->x_ =-1;
	if (pot3>170) status->y_ =1;
	if (pot3<60) status->y_ =-1;

	status->fire_ = (kbcode==0x14) || (!(1&*atari_trig0&*atari_trig1&*atari_trig2&*atari_trig3));

	if (controls!=0)
	{
		status->y_ = !!(controls&0x2) -((unsigned int)!!(controls&0x1));
		status->x_ = !!(controls&0x8) -((unsigned int)!!(controls&0x4));
		status->fire_ = !!(controls&0x10);
		status->escape_ = !!(controls&0x20);
	}

	//if (porta != 0xff)
	//printf("%02x %x %x %x\n",porta,status->x_,status->y_,status->fire_);
/*
	if (0==(porta&0x2)) // down
	{
		status->y_ =1;
	}
	else if (0==(porta&0x1)) // up
	{
		status->y_ =-1;
	}
	if (0==(porta&0x8)) // right
	{
		status->x_ = 1;
	}
	else if (0==(porta&0x4)) // left
	{
		status->x_ = -1;
	}
	if (0==(1&*atari_trig0)) // fire
	{
		status->fire_ = 1;
	}
*/
}

void joystick_wait(struct joystick_status * status, enum JoyWait waitFor)
{
	while (1)
	{
		joystick_poll(status);
		switch (waitFor)
		{
		case WAIT_QUIET:
			if (status->x_ == 0 && status->y_ == 0 && status->fire_ == 0) return;
			break;
		case WAIT_FIRE:
			if (status->fire_ == 1 || status->escape_==1) return;
			break;
		case WAIT_EITHER:
			if (status->fire_ == 1) return;
			// fall through
		case WAIT_MOVE:
			if (status->x_ !=0 || status->y_ != 0 || status->escape_==1) return;
			break;
		}
	}
}

