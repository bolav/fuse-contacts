using Uno;
using Uno.Collections;
using Fuse;
using Bolav.ForeignHelpers;

public extern(!Mobile) class ContactsImpl
{
	public static void GetAllImpl(ListDict ret) {
		debug_log("Contacts only working on mobile");
	} 
}
