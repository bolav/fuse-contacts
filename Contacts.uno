using Uno;
using Uno.UX;
using Uno.Threading;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Bolav.ForeignHelpers;

[UXGlobalModule]
public class Contacts : NativeModule {

	static readonly Contacts _instance;

	public Contacts()
	{
		if (_instance != null) return;
		_instance = this;
		Resource.SetGlobalKey(_instance, "Contacts");
		
		AddMember(new NativePromise<string, string>("authorize", Authorize, null));
		AddMember(new NativeFunction("getAll", (NativeCallback)GetAll));
	}

	object GetAll (Context c, object[] args)
	{
		var a = new JSList(c);
		ContactsImpl.GetAllImpl(a);
		return a.GetScriptingArray();
	}

	Future<string> Authorize (object[] args)
	{
		return ContactsImpl.AuthorizeImpl();
	}


}

