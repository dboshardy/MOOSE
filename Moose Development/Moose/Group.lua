--- This module contains the GROUP class.
-- 
-- 1) @{Group#GROUP} class, extends @{Controllable#CONTROLLABLE}
-- =============================================================
-- The @{Group#GROUP} class is a wrapper class to handle the DCS Group objects:
--
--  * Support all DCS Group APIs.
--  * Enhance with Group specific APIs not in the DCS Group API set.
--  * Handle local Group Controller.
--  * Manage the "state" of the DCS Group.
--
-- **IMPORTANT: ONE SHOULD NEVER SANATIZE these GROUP OBJECT REFERENCES! (make the GROUP object references nil).**
--
-- 1.1) GROUP reference methods
-- -----------------------
-- For each DCS Group object alive within a running mission, a GROUP wrapper object (instance) will be created within the _@{DATABASE} object.
-- This is done at the beginning of the mission (when the mission starts), and dynamically when new DCS Group objects are spawned (using the @{SPAWN} class).
--
-- The GROUP class does not contain a :New() method, rather it provides :Find() methods to retrieve the object reference
-- using the DCS Group or the DCS GroupName.
--
-- Another thing to know is that GROUP objects do not "contain" the DCS Group object.
-- The GROUP methods will reference the DCS Group object by name when it is needed during API execution.
-- If the DCS Group object does not exist or is nil, the GROUP methods will return nil and log an exception in the DCS.log file.
--
-- The GROUP class provides the following functions to retrieve quickly the relevant GROUP instance:
--
--  * @{#GROUP.Find}(): Find a GROUP instance from the _DATABASE object using a DCS Group object.
--  * @{#GROUP.FindByName}(): Find a GROUP instance from the _DATABASE object using a DCS Group name.
--
-- 1.2) GROUP task methods
-- -----------------------
-- Several group task methods are available that help you to prepare tasks. 
-- These methods return a string consisting of the task description, which can then be given to either a @{Group#GROUP.PushTask} or @{Group#SetTask} method to assign the task to the GROUP.
-- Tasks are specific for the category of the GROUP, more specific, for AIR, GROUND or AIR and GROUND. 
-- Each task description where applicable indicates for which group category the task is valid.
-- There are 2 main subdivisions of tasks: Assigned tasks and EnRoute tasks.
-- 
-- ### 1.2.1) Assigned task methods
-- 
-- Assigned task methods make the group execute the task where the location of the (possible) targets of the task are known before being detected.
-- This is different from the EnRoute tasks, where the targets of the task need to be detected before the task can be executed.
-- 
-- Find below a list of the **assigned task** methods:
-- 
--   * @{#GROUP.TaskAttackGroup}: (AIR) Attack a Group.
--   * @{#GROUP.TaskAttackMapObject}: (AIR) Attacking the map object (building, structure, e.t.c).
--   * @{#GROUP.TaskAttackUnit}: (AIR) Attack the Unit.
--   * @{#GROUP.TaskBombing}: (AIR) Delivering weapon at the point on the ground.
--   * @{#GROUP.TaskBombingRunway}: (AIR) Delivering weapon on the runway.
--   * @{#GROUP.TaskEmbarking}: (AIR) Move the group to a Vec2 Point, wait for a defined duration and embark a group.
--   * @{#GROUP.TaskEmbarkToTransport}: (GROUND) Embark to a Transport landed at a location.
--   * @{#GROUP.TaskEscort}: (AIR) Escort another airborne group. 
--   * @{#GROUP.TaskFAC_AttackGroup}: (AIR + GROUND) The task makes the group/unit a FAC and orders the FAC to control the target (enemy ground group) destruction.
--   * @{#GROUP.TaskFireAtPoint}: (GROUND) Fire at a VEC2 point until ammunition is finished.
--   * @{#GROUP.TaskFollow}: (AIR) Following another airborne group.
--   * @{#GROUP.TaskHold}: (GROUND) Hold ground group from moving.
--   * @{#GROUP.TaskHoldPosition}: (AIR) Hold position at the current position of the first unit of the group.
--   * @{#GROUP.TaskLand}: (AIR HELICOPTER) Landing at the ground. For helicopters only.
--   * @{#GROUP.TaskLandAtZone}: (AIR) Land the group at a @{Zone#ZONE_RADIUS).
--   * @{#GROUP.TaskOrbitCircle}: (AIR) Orbit at the current position of the first unit of the group at a specified alititude.
--   * @{#GROUP.TaskOrbitCircleAtVec2}: (AIR) Orbit at a specified position at a specified alititude during a specified duration with a specified speed.
--   * @{#GROUP.TaskRefueling}: (AIR) Refueling from the nearest tanker. No parameters.
--   * @{#GROUP.TaskRoute}: (AIR + GROUND) Return a Misson task to follow a given route defined by Points.
--   * @{#GROUP.TaskRouteToVec2}: (AIR + GROUND) Make the Group move to a given point.
--   * @{#GROUP.TaskRouteToVec3}: (AIR + GROUND) Make the Group move to a given point.
--   * @{#GROUP.TaskRouteToZone}: (AIR + GROUND) Route the group to a given zone.
--   * @{#GROUP.TaskReturnToBase}: (AIR) Route the group to an airbase.
--
-- ### 1.2.2) EnRoute task methods
-- 
-- EnRoute tasks require the targets of the task need to be detected by the group (using its sensors) before the task can be executed:
-- 
--   * @{#GROUP.EnRouteTaskAWACS}: (AIR) Aircraft will act as an AWACS for friendly units (will provide them with information about contacts). No parameters.
--   * @{#GROUP.EnRouteTaskEngageGroup}: (AIR) Engaging a group. The task does not assign the target group to the unit/group to attack now; it just allows the unit/group to engage the target group as well as other assigned targets.
--   * @{#GROUP.EnRouteTaskEngageTargets}: (AIR) Engaging targets of defined types.
--   * @{#GROUP.EnRouteTaskEWR}: (AIR) Attack the Unit.
--   * @{#GROUP.EnRouteTaskFAC}: (AIR + GROUND) The task makes the group/unit a FAC and lets the FAC to choose a targets (enemy ground group) around as well as other assigned targets.
--   * @{#GROUP.EnRouteTaskFAC_EngageGroup}: (AIR + GROUND) The task makes the group/unit a FAC and lets the FAC to choose the target (enemy ground group) as well as other assigned targets.
--   * @{#GROUP.EnRouteTaskTanker}: (AIR) Aircraft will act as a tanker for friendly units. No parameters.
-- 
-- ### 1.2.3) Preparation task methods
-- 
-- There are certain task methods that allow to tailor the task behaviour:
--
--   * @{#GROUP.TaskWrappedAction}: Return a WrappedAction Task taking a Command.
--   * @{#GROUP.TaskCombo}: Return a Combo Task taking an array of Tasks.
--   * @{#GROUP.TaskCondition}: Return a condition section for a controlled task.
--   * @{#GROUP.TaskControlled}: Return a Controlled Task taking a Task and a TaskCondition.
-- 
-- ### 1.2.4) Obtain the mission from group templates
-- 
-- Group templates contain complete mission descriptions. Sometimes you want to copy a complete mission from a group and assign it to another:
-- 
--   * @{#GROUP.TaskMission}: (AIR + GROUND) Return a mission task from a mission template.
--
-- 1.3) GROUP Command methods
-- --------------------------
-- Group **command methods** prepare the execution of commands using the @{#GROUP.SetCommand} method:
-- 
--   * @{#GROUP.CommandDoScript}: Do Script command.
--   * @{#GROUP.CommandSwitchWayPoint}: Perform a switch waypoint command.
-- 
-- 1.4) GROUP Option methods
-- -------------------------
-- Group **Option methods** change the behaviour of the Group while being alive.
-- 
-- ### 1.4.1) Rule of Engagement:
-- 
--   * @{#GROUP.OptionROEWeaponFree} 
--   * @{#GROUP.OptionROEOpenFire}
--   * @{#GROUP.OptionROEReturnFire}
--   * @{#GROUP.OptionROEEvadeFire}
-- 
-- To check whether an ROE option is valid for a specific group, use:
-- 
--   * @{#GROUP.OptionROEWeaponFreePossible} 
--   * @{#GROUP.OptionROEOpenFirePossible}
--   * @{#GROUP.OptionROEReturnFirePossible}
--   * @{#GROUP.OptionROEEvadeFirePossible}
-- 
-- ### 1.4.2) Rule on thread:
-- 
--   * @{#GROUP.OptionROTNoReaction}
--   * @{#GROUP.OptionROTPassiveDefense}
--   * @{#GROUP.OptionROTEvadeFire}
--   * @{#GROUP.OptionROTVertical}
-- 
-- To test whether an ROT option is valid for a specific group, use:
-- 
--   * @{#GROUP.OptionROTNoReactionPossible}
--   * @{#GROUP.OptionROTPassiveDefensePossible}
--   * @{#GROUP.OptionROTEvadeFirePossible}
--   * @{#GROUP.OptionROTVerticalPossible}
-- 
-- 1.5) GROUP Zone validation methods
-- ----------------------------------
-- The group can be validated whether it is completely, partly or not within a @{Zone}.
-- Use the following Zone validation methods on the group:
-- 
--   * @{#GROUP.IsCompletelyInZone}: Returns true if all units of the group are within a @{Zone}.
--   * @{#GROUP.IsPartlyInZone}: Returns true if some units of the group are within a @{Zone}.
--   * @{#GROUP.IsNotInZone}: Returns true if none of the group units of the group are within a @{Zone}.
--   
-- The zone can be of any @{Zone} class derived from @{Zone#ZONE_BASE}. So, these methods are polymorphic to the zones tested on.
-- 
-- @module Group
-- @author FlightControl

--- The GROUP class
-- @type GROUP
-- @extends Controllable#CONTROLLABLE
-- @field #string GroupName The name of the group.
GROUP = {
  ClassName = "GROUP",
}

--- Create a new GROUP from a DCSGroup
-- @param #GROUP self
-- @param DCSGroup#Group GroupName The DCS Group name
-- @return #GROUP self
function GROUP:Register( GroupName )
  local self = BASE:Inherit( self, CONTROLLABLE:New( GroupName ) )
  self:F2( GroupName )
  self.GroupName = GroupName
  return self
end

-- Reference methods.

--- Find the GROUP wrapper class instance using the DCS Group.
-- @param #GROUP self
-- @param DCSGroup#Group DCSGroup The DCS Group.
-- @return #GROUP The GROUP.
function GROUP:Find( DCSGroup )

  local GroupName = DCSGroup:getName() -- Group#GROUP
  local GroupFound = _DATABASE:FindGroup( GroupName )
  GroupFound:E( { GroupName, GroupFound:GetClassNameAndID() } )
  return GroupFound
end

--- Find the created GROUP using the DCS Group Name.
-- @param #GROUP self
-- @param #string GroupName The DCS Group Name.
-- @return #GROUP The GROUP.
function GROUP:FindByName( GroupName )

  local GroupFound = _DATABASE:FindGroup( GroupName )
  return GroupFound
end

-- DCS Group methods support.

--- Returns the DCS Group.
-- @param #GROUP self
-- @return DCSGroup#Group The DCS Group.
function GROUP:GetDCSObject()
  local DCSGroup = Group.getByName( self.GroupName )

  if DCSGroup then
    return DCSGroup
  end

  return nil
end


--- Returns if the DCS Group is alive.
-- When the group exists at run-time, this method will return true, otherwise false.
-- @param #GROUP self
-- @return #boolean true if the DCS Group is alive.
function GROUP:IsAlive()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupIsAlive = DCSGroup:isExist()
    self:T3( GroupIsAlive )
    return GroupIsAlive
  end

  return nil
end

--- Destroys the DCS Group and all of its DCS Units.
-- Note that this destroy method also raises a destroy event at run-time.
-- So all event listeners will catch the destroy event of this DCS Group.
-- @param #GROUP self
function GROUP:Destroy()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    for Index, UnitData in pairs( DCSGroup:getUnits() ) do
      self:CreateEventCrash( timer.getTime(), UnitData )
    end
    DCSGroup:destroy()
    DCSGroup = nil
  end

  return nil
end

--- Returns category of the DCS Group.
-- @param #GROUP self
-- @return DCSGroup#Group.Category The category ID
function GROUP:GetCategory()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    local GroupCategory = DCSGroup:getCategory()
    self:T3( GroupCategory )
    return GroupCategory
  end

  return nil
end

--- Returns the category name of the DCS Group.
-- @param #GROUP self
-- @return #string Category name = Helicopter, Airplane, Ground Unit, Ship
function GROUP:GetCategoryName()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    local CategoryNames = {
      [Group.Category.AIRPLANE] = "Airplane",
      [Group.Category.HELICOPTER] = "Helicopter",
      [Group.Category.GROUND] = "Ground Unit",
      [Group.Category.SHIP] = "Ship",
    }
    local GroupCategory = DCSGroup:getCategory()
    self:T3( GroupCategory )

    return CategoryNames[GroupCategory]
  end

  return nil
end


--- Returns the coalition of the DCS Group.
-- @param #GROUP self
-- @return DCSCoalitionObject#coalition.side The coalition side of the DCS Group.
function GROUP:GetCoalition()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    local GroupCoalition = DCSGroup:getCoalition()
    self:T3( GroupCoalition )
    return GroupCoalition
  end

  return nil
end

--- Returns the country of the DCS Group.
-- @param #GROUP self
-- @return DCScountry#country.id The country identifier.
-- @return #nil The DCS Group is not existing or alive.
function GROUP:GetCountry()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    local GroupCountry = DCSGroup:getUnit(1):getCountry()
    self:T3( GroupCountry )
    return GroupCountry
  end

  return nil
end

--- Returns the UNIT wrapper class with number UnitNumber.
-- If the underlying DCS Unit does not exist, the method will return nil. .
-- @param #GROUP self
-- @param #number UnitNumber The number of the UNIT wrapper class to be returned.
-- @return Unit#UNIT The UNIT wrapper class.
function GROUP:GetUnit( UnitNumber )
  self:F2( { self.GroupName, UnitNumber } )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local UnitFound = UNIT:Find( DCSGroup:getUnit( UnitNumber ) )
    self:T3( UnitFound.UnitName )
    self:T2( UnitFound )
    return UnitFound
  end

  return nil
end

--- Returns the DCS Unit with number UnitNumber.
-- If the underlying DCS Unit does not exist, the method will return nil. .
-- @param #GROUP self
-- @param #number UnitNumber The number of the DCS Unit to be returned.
-- @return DCSUnit#Unit The DCS Unit.
function GROUP:GetDCSUnit( UnitNumber )
  self:F2( { self.GroupName, UnitNumber } )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local DCSUnitFound = DCSGroup:getUnit( UnitNumber )
    self:T3( DCSUnitFound )
    return DCSUnitFound
  end

  return nil
end

--- Returns current size of the DCS Group.
-- If some of the DCS Units of the DCS Group are destroyed the size of the DCS Group is changed.
-- @param #GROUP self
-- @return #number The DCS Group size.
function GROUP:GetSize()
  self:F2( { self.GroupName } )
  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupSize = DCSGroup:getSize()
    self:T3( GroupSize )
    return GroupSize
  end

  return nil
end

---
--- Returns the initial size of the DCS Group.
-- If some of the DCS Units of the DCS Group are destroyed, the initial size of the DCS Group is unchanged.
-- @param #GROUP self
-- @return #number The DCS Group initial size.
function GROUP:GetInitialSize()
  self:F2( { self.GroupName } )
  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupInitialSize = DCSGroup:getInitialSize()
    self:T3( GroupInitialSize )
    return GroupInitialSize
  end

  return nil
end

--- Returns the UNITs wrappers of the DCS Units of the DCS Group.
-- @param #GROUP self
-- @return #table The UNITs wrappers.
function GROUP:GetUnits()
  self:F2( { self.GroupName } )
  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local DCSUnits = DCSGroup:getUnits()
    local Units = {}
    for Index, UnitData in pairs( DCSUnits ) do
      Units[#Units+1] = UNIT:Find( UnitData )
    end
    self:T3( Units )
    return Units
  end

  return nil
end


--- Returns the DCS Units of the DCS Group.
-- @param #GROUP self
-- @return #table The DCS Units.
function GROUP:GetDCSUnits()
  self:F2( { self.GroupName } )
  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local DCSUnits = DCSGroup:getUnits()
    self:T3( DCSUnits )
    return DCSUnits
  end

  return nil
end


--- Activates a GROUP.
-- @param #GROUP self
function GROUP:Activate()
  self:F2( { self.GroupName } )
  trigger.action.activateGroup( self:GetDCSObject() )
  return self:GetDCSObject()
end


--- Gets the type name of the group.
-- @param #GROUP self
-- @return #string The type name of the group.
function GROUP:GetTypeName()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupTypeName = DCSGroup:getUnit(1):getTypeName()
    self:T3( GroupTypeName )
    return( GroupTypeName )
  end

  return nil
end

--- Gets the CallSign of the first DCS Unit of the DCS Group.
-- @param #GROUP self
-- @return #string The CallSign of the first DCS Unit of the DCS Group.
function GROUP:GetCallsign()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupCallSign = DCSGroup:getUnit(1):getCallsign()
    self:T3( GroupCallSign )
    return GroupCallSign
  end

  return nil
end

--- Returns the current point (Vec2 vector) of the first DCS Unit in the DCS Group.
-- @param #GROUP self
-- @return DCSTypes#Vec2 Current Vec2 point of the first DCS Unit of the DCS Group.
function GROUP:GetPointVec2()
  self:F2( self.GroupName )

  local UnitPoint = self:GetUnit(1)
  UnitPoint:GetPointVec2()
  local GroupPointVec2 = UnitPoint:GetPointVec2()
  self:T3( GroupPointVec2 )
  return GroupPointVec2
end

--- Returns the current point (Vec3 vector) of the first DCS Unit in the DCS Group.
-- @return DCSTypes#Vec3 Current Vec3 point of the first DCS Unit of the DCS Group.
function GROUP:GetPointVec3()
  self:F2( self.GroupName )

  local GroupPointVec3 = self:GetUnit(1):GetPointVec3()
  self:T3( GroupPointVec3 )
  return GroupPointVec3
end



-- Is Zone Functions

--- Returns true if all units of the group are within a @{Zone}.
-- @param #GROUP self
-- @param Zone#ZONE_BASE Zone The zone to test.
-- @return #boolean Returns true if the Group is completely within the @{Zone#ZONE_BASE}
function GROUP:IsCompletelyInZone( Zone )
  self:F2( { self.GroupName, Zone } )
  
  for UnitID, UnitData in pairs( self:GetUnits() ) do
    local Unit = UnitData -- Unit#UNIT
    if Zone:IsPointVec3InZone( Unit:GetPointVec3() ) then
    else
      return false
    end
  end
  
  return true
end

--- Returns true if some units of the group are within a @{Zone}.
-- @param #GROUP self
-- @param Zone#ZONE_BASE Zone The zone to test.
-- @return #boolean Returns true if the Group is completely within the @{Zone#ZONE_BASE}
function GROUP:IsPartlyInZone( Zone )
  self:F2( { self.GroupName, Zone } )
  
  for UnitID, UnitData in pairs( self:GetUnits() ) do
    local Unit = UnitData -- Unit#UNIT
    if Zone:IsPointVec3InZone( Unit:GetPointVec3() ) then
      return true
    end
  end
  
  return false
end

--- Returns true if none of the group units of the group are within a @{Zone}.
-- @param #GROUP self
-- @param Zone#ZONE_BASE Zone The zone to test.
-- @return #boolean Returns true if the Group is completely within the @{Zone#ZONE_BASE}
function GROUP:IsNotInZone( Zone )
  self:F2( { self.GroupName, Zone } )
  
  for UnitID, UnitData in pairs( self:GetUnits() ) do
    local Unit = UnitData -- Unit#UNIT
    if Zone:IsPointVec3InZone( Unit:GetPointVec3() ) then
      return false
    end
  end
  
  return true
end

--- Returns if the group is of an air category.
-- If the group is a helicopter or a plane, then this method will return true, otherwise false.
-- @param #GROUP self
-- @return #boolean Air category evaluation result.
function GROUP:IsAir()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local IsAirResult = DCSGroup:getCategory() == Group.Category.AIRPLANE or DCSGroup:getCategory() == Group.Category.HELICOPTER
    self:T3( IsAirResult )
    return IsAirResult
  end

  return nil
end

--- Returns if the DCS Group contains Helicopters.
-- @param #GROUP self
-- @return #boolean true if DCS Group contains Helicopters.
function GROUP:IsHelicopter()
  self:F2( self.GroupName )

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupCategory = DCSGroup:getCategory()
    self:T2( GroupCategory )
    return GroupCategory == Group.Category.HELICOPTER
  end

  return nil
end

--- Returns if the DCS Group contains AirPlanes.
-- @param #GROUP self
-- @return #boolean true if DCS Group contains AirPlanes.
function GROUP:IsAirPlane()
  self:F2()

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupCategory = DCSGroup:getCategory()
    self:T2( GroupCategory )
    return GroupCategory == Group.Category.AIRPLANE
  end

  return nil
end

--- Returns if the DCS Group contains Ground troops.
-- @param #GROUP self
-- @return #boolean true if DCS Group contains Ground troops.
function GROUP:IsGround()
  self:F2()

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupCategory = DCSGroup:getCategory()
    self:T2( GroupCategory )
    return GroupCategory == Group.Category.GROUND
  end

  return nil
end

--- Returns if the DCS Group contains Ships.
-- @param #GROUP self
-- @return #boolean true if DCS Group contains Ships.
function GROUP:IsShip()
  self:F2()

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local GroupCategory = DCSGroup:getCategory()
    self:T2( GroupCategory )
    return GroupCategory == Group.Category.SHIP
  end

  return nil
end

--- Returns if all units of the group are on the ground or landed.
-- If all units of this group are on the ground, this function will return true, otherwise false.
-- @param #GROUP self
-- @return #boolean All units on the ground result.
function GROUP:AllOnGround()
  self:F2()

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local AllOnGroundResult = true

    for Index, UnitData in pairs( DCSGroup:getUnits() ) do
      if UnitData:inAir() then
        AllOnGroundResult = false
      end
    end

    self:T3( AllOnGroundResult )
    return AllOnGroundResult
  end

  return nil
end

--- Returns the current maximum velocity of the group.
-- Each unit within the group gets evaluated, and the maximum velocity (= the unit which is going the fastest) is returned.
-- @param #GROUP self
-- @return #number Maximum velocity found.
function GROUP:GetMaxVelocity()
  self:F2()

  local DCSGroup = self:GetDCSObject()

  if DCSGroup then
    local MaxVelocity = 0

    for Index, UnitData in pairs( DCSGroup:getUnits() ) do

      local Velocity = UnitData:getVelocity()
      local VelocityTotal = math.abs( Velocity.x ) + math.abs( Velocity.y ) + math.abs( Velocity.z )

      if VelocityTotal < MaxVelocity then
        MaxVelocity = VelocityTotal
      end
    end

    return MaxVelocity
  end

  return nil
end

--- Returns the current minimum height of the group.
-- Each unit within the group gets evaluated, and the minimum height (= the unit which is the lowest elevated) is returned.
-- @param #GROUP self
-- @return #number Minimum height found.
function GROUP:GetMinHeight()
  self:F2()

end

--- Returns the current maximum height of the group.
-- Each unit within the group gets evaluated, and the maximum height (= the unit which is the highest elevated) is returned.
-- @param #GROUP self
-- @return #number Maximum height found.
function GROUP:GetMaxHeight()
  self:F2()

end

--- @param Group#GROUP self
function GROUP:Respawn( Template )

  local Vec3 = self:GetPointVec3()
  --Template.x = Vec3.x
  --Template.y = Vec3.z
  Template.x = nil
  Template.y = nil
  
  self:E( #Template.units )
  for UnitID, UnitData in pairs( self:GetUnits() ) do
    local GroupUnit = UnitData -- Unit#UNIT
    self:E( GroupUnit:GetName() )
    if GroupUnit:IsAlive() then
      local GroupUnitVec3 = GroupUnit:GetPointVec3()
      local GroupUnitHeading = GroupUnit:GetHeading()
      Template.units[UnitID].alt = GroupUnitVec3.y
      Template.units[UnitID].x = GroupUnitVec3.x
      Template.units[UnitID].y = GroupUnitVec3.z
      Template.units[UnitID].heading = GroupUnitHeading
      self:E( { UnitID, Template.units[UnitID], Template.units[UnitID] } )
    end
  end
  
  _DATABASE:Spawn( Template )

end

function GROUP:GetTemplate()

  return _DATABASE.Templates.Groups[self:GetName()].Template

end

--- Return the mission template of the group.
-- @param #GROUP self
-- @return #table The MissionTemplate
function GROUP:GetTaskMission()
  self:F2( self.GroupName )

  return routines.utils.deepCopy( _DATABASE.Templates.Groups[self.GroupName].Template )
end

--- Return the mission route of the group.
-- @param #GROUP self
-- @return #table The mission route defined by points.
function GROUP:GetTaskRoute()
  self:F2( self.GroupName )

  return routines.utils.deepCopy( _DATABASE.Templates.Groups[self.GroupName].Template.route.points )
end

--- Return the route of a group by using the @{Database#DATABASE} class.
-- @param #GROUP self
-- @param #number Begin The route point from where the copy will start. The base route point is 0.
-- @param #number End The route point where the copy will end. The End point is the last point - the End point. The last point has base 0.
-- @param #boolean Randomize Randomization of the route, when true.
-- @param #number Radius When randomization is on, the randomization is within the radius.
function GROUP:CopyRoute( Begin, End, Randomize, Radius )
  self:F2( { Begin, End } )

  local Points = {}

  -- Could be a Spawned Group
  local GroupName = string.match( self:GetName(), ".*#" )
  if GroupName then
    GroupName = GroupName:sub( 1, -2 )
  else
    GroupName = self:GetName()
  end

  self:T3( { GroupName } )

  local Template = _DATABASE.Templates.Groups[GroupName].Template

  if Template then
    if not Begin then
      Begin = 0
    end
    if not End then
      End = 0
    end

    for TPointID = Begin + 1, #Template.route.points - End do
      if Template.route.points[TPointID] then
        Points[#Points+1] = routines.utils.deepCopy( Template.route.points[TPointID] )
        if Randomize then
          if not Radius then
            Radius = 500
          end
          Points[#Points].x = Points[#Points].x + math.random( Radius * -1, Radius )
          Points[#Points].y = Points[#Points].y + math.random( Radius * -1, Radius )
        end
      end
    end
    return Points
  else
    error( "Template not found for Group : " .. GroupName )
  end

  return nil
end


-- Message APIs

--- Returns a message for a coalition or a client.
-- @param #GROUP self
-- @param #string Message The message text
-- @param DCSTypes#Duration Duration The duration of the message.
-- @return Message#MESSAGE
function GROUP:Message( Message, Duration )
  self:F2( { Message, Duration } )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    return MESSAGE:New( Message, Duration, self:GetCallsign() .. " (" .. self:GetTypeName() .. ")" )
  end

  return nil
end

--- Send a message to all coalitions.
-- The message will appear in the message area. The message will begin with the callsign of the group and the type of the first unit sending the message.
-- @param #GROUP self
-- @param #string Message The message text
-- @param DCSTypes#Duration Duration The duration of the message.
function GROUP:MessageToAll( Message, Duration )
  self:F2( { Message, Duration } )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    self:Message( Message, Duration ):ToAll()
  end

  return nil
end

--- Send a message to the red coalition.
-- The message will appear in the message area. The message will begin with the callsign of the group and the type of the first unit sending the message.
-- @param #GROUP self
-- @param #string Message The message text
-- @param DCSTYpes#Duration Duration The duration of the message.
function GROUP:MessageToRed( Message, Duration )
  self:F2( { Message, Duration } )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    self:Message( Message, Duration ):ToRed()
  end

  return nil
end

--- Send a message to the blue coalition.
-- The message will appear in the message area. The message will begin with the callsign of the group and the type of the first unit sending the message.
-- @param #GROUP self
-- @param #string Message The message text
-- @param DCSTypes#Duration Duration The duration of the message.
function GROUP:MessageToBlue( Message, Duration )
  self:F2( { Message, Duration } )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    self:Message( Message, Duration ):ToBlue()
  end

  return nil
end

--- Send a message to a client.
-- The message will appear in the message area. The message will begin with the callsign of the group and the type of the first unit sending the message.
-- @param #GROUP self
-- @param #string Message The message text
-- @param DCSTypes#Duration Duration The duration of the message.
-- @param Client#CLIENT Client The client object receiving the message.
function GROUP:MessageToClient( Message, Duration, Client )
  self:F2( { Message, Duration } )

  local DCSGroup = self:GetDCSObject()
  if DCSGroup then
    self:Message( Message, Duration ):ToClient( Client )
  end

  return nil
end
