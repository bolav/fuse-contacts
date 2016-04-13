using Uno;
using Uno.Threading;
using Fuse.Scripting;
using Fuse.Reactive;
using Bolav.ForeignHelpers;

public class Contacts : NativeModule {

	public Contacts()
	{
		AddMember(new NativePromise<string, string>("authorize", Authorize, null));
		AddMember(new NativeFunction("getAll", (NativeCallback)GetAll));
	}

	object GetAll (Context c, object[] args)
	{
		var a = new JSListDict(c);
		ContactsImpl.GetAllImpl(a);
		return a.GetScriptingArray();
	}

	Future<string> Authorize (object[] args)
	{
		return ContactsImpl.AuthorizeImpl();
	}


}

