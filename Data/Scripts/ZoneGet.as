class ZoneGet : ScriptObject
{
	String getBoxNodeName;

	private uint boxCount = 0;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName )
		{
			++boxCount;

			if (boxCount == 1)
			{
				VariantMap vmap;
				vmap["next_level"] = true;
				SendEvent("innerEvent", vmap);
			}
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName ) { --boxCount; }
	}
}
