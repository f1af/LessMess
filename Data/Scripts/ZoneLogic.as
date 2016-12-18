#include "Scripts/GameLogicEventFunc.as"
#include "Scripts/GameLogicMenuFunc.as"

class ZoneGet : ScriptObject
{
	String getBoxNodeName;

	private uint boxCount = 0;
	private int zoneType = 0;

	void DelayedStart()
	{
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
		GameLogicMenuFunc_updateBoxCount(0);

		zoneType = node.vars["ZoneType"].GetInt();

		node.GetComponents("StaticSprite2D")[zoneType].enabled = true;
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName and nodeA.vars["ZoneType"].GetInt() == nodeB.vars["boxType"].GetInt() )
		{
			GameLogicMenuFunc_updateBoxCount(++boxCount);

			if (boxCount == 4)
			{
				GameLogicEventFunc_nextLevel();
			}
		}
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == getBoxNodeName and nodeA.vars["ZoneType"].GetInt() == nodeB.vars["boxType"].GetInt() )
		{
			GameLogicMenuFunc_updateBoxCount(--boxCount);
		}
	}
}

class ZoneSpawn : ScriptObject
{
	String spawnBoxXML;
	String spawnBoxNodeName;

	private Timer timer;
	private XMLFile@ xmlfile;
	private bool doSpawn = true;

	void DelayedStart()
	{
		xmlfile = cache.GetResource("XMLFile", spawnBoxXML);
	    SubscribeToEvent("PhysicsBeginContact2D", "HandleCollisionStart");
	    SubscribeToEvent("PhysicsEndContact2D", "HandleCollisionEnd");
	}

	void HandleCollisionStart(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == spawnBoxNodeName ) { doSpawn = false; }
	}

	void HandleCollisionEnd(StringHash eventType, VariantMap& eventData)
	{
		Node@ nodeA = eventData["NodeA"].GetPtr();
		Node@ nodeB = eventData["NodeB"].GetPtr();

		if ( nodeA.name == node.name and nodeB.name == spawnBoxNodeName ) { doSpawn = true; }
	}

    void FixedUpdate(float timeStep)
    {
    	if ( timer.GetMSec(false) > 5000 )
    	{
    		timer.Reset();
		    if (doSpawn and (xmlfile !is null))
		    {
		        Node@ newNode = scene.CreateChild();
		        int boxType = RandomInt(3);
		        if (newNode.LoadXML(xmlfile.GetRoot(), true))
		        {
					newNode.SetTransform(node.position, node.rotation);		        	
					newNode.GetComponents("StaticSprite2D")[boxType].enabled = true;
					newNode.vars["boxType"] = boxType;
		        }
		        newNode.temporary = true;
	    	}
	    }
	}
}