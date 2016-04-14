using Uno;
using Uno.Collections;
using Fuse;
using Bolav.ForeignHelpers;
using Uno.Threading;

public extern(!Mobile) class ContactsImpl
{
	public static void GetAllImpl(ListDict ret) {
		debug_log("Contacts only working on mobile");
	} 

	public static Future<string> AuthorizeImpl()
	{
		var p = new Promise<string>();
		p.Reject(new Exception("Contacts not available on current platform"));
	}
}
