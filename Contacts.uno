using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Bolav.ForeignHelpers;

public class Contacts : NativeModule {

	public Contacts()
	{
		AddMember(new NativeFunction("getAll", (NativeCallback)GetAll));
	}

	// http://stackoverflow.com/questions/3747844/get-a-list-of-all-contacts-on-ios
	object GetAll (Context c, object[] args)
	{
		var a = new JSListDict(c);
		ContactsImpl.GetAllImpl(a);
		return a.GetScriptingArray();
	}

}

