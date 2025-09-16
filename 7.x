reset
-- G5) GRANT when BOTH user location and object location satisfy permission via ancestors.
-- Setup: Root encloses Leaf; user at Leaf; object at Leaf.
-- Permission lists Root for both roleLoc & objLoc, so both are satisfied via ancestors.

------------------------------------------------------------
-- 1) LOCATIONS
------------------------------------------------------------
!create L_root : Location
!set L_root.name := 'Root'
!create L_leaf : Location
!set L_leaf.name := 'Leaf'
!insert (L_root, L_leaf) into LocationHierarchy   -- Root encloses Leaf

------------------------------------------------------------
-- 2) ACTIONS
------------------------------------------------------------
!create aRead : Action
!set aRead.name := 'read'

------------------------------------------------------------
-- 3) RESOURCE at Leaf (supports read)
------------------------------------------------------------
!create resA : Resource
!set resA.name := 'DocA'
!set resA.resourceBasedDynamicSeparationOfDuty := false
!set resA.historyBasedDynamicSeparationOfDuty := false
!insert (resA, aRead)  into ResourceAction
!insert (resA, L_leaf) into ResourceLocation

------------------------------------------------------------
-- 4) ROLE 
------------------------------------------------------------
!create rEng : Role
!set rEng.name := 'Engineer'
!set rEng.maxMembers := 10
!set rEng.maxJuniors := 10
!set rEng.exclusiveJuniorsAllowed := false
!insert (rEng, L_root) into RoleAssignLocation
!insert (rEng, L_leaf) into RoleAssignLocation
!insert (rEng, L_root) into RoleActivateLocation
!insert (rEng, L_leaf) into RoleActivateLocation

------------------------------------------------------------
-- 5) PERMISSIONS
-- pRoot: roleLoc=objLoc=Root (ancestor of Leaf) -> used for the grant
------------------------------------------------------------
!create pRoot : Permission
!set pRoot.name := 'pRoot'
!set pRoot.maxRoles := 10
!set pRoot.maxSessions := 10
!insert (pRoot, resA)   into PermissionResource
!insert (pRoot, aRead)  into PermissionAction
!insert (pRoot, L_root) into PermissionRoleLocation
!insert (pRoot, L_root) into PermissionObjectLocation

!create pLeafPad : Permission
!set pLeafPad.name := 'pLeafPad'
!set pLeafPad.maxRoles := 10
!set pLeafPad.maxSessions := 10
!insert (pLeafPad, resA)   into PermissionResource
!insert (pLeafPad, aRead)  into PermissionAction
!insert (pLeafPad, L_leaf) into PermissionRoleLocation
!insert (pLeafPad, L_leaf) into PermissionObjectLocation

-- Bind both permissions to the role (only pRoot will matter for the query)
!insert (rEng, pRoot)    into PermissionAssignment
!insert (rEng, pLeafPad) into PermissionAssignment

------------------------------------------------------------
-- 6) USER, SNAPSHOTS, LOCATIONS
------------------------------------------------------------
!create u1 : User
!set u1.name := 'U1'
!set u1.maxRoles := 5
!set u1.maxRolesRespectingHierarchy := false
!set u1.maxSessions := 5

!create t0 : Snapshot
!create t1 : Snapshot
!insert (t0, t1) into PredSuccSnapshot
!insert (t0, u1) into SnapshotUser        

-- Exactly one UserAt per (user, snapshot)
!create ua0 : UserAt
!insert (u1, ua0)     into UserAtUser
!insert (L_leaf, ua0) into UserAtLocation
!insert (t0, ua0)     into UserAtSnapshot

!create ua1 : UserAt
!insert (u1, ua1)     into UserAtUser
!insert (L_leaf, ua1) into UserAtLocation
!insert (t1, ua1)     into UserAtSnapshot

------------------------------------------------------------
-- 7) SESSION, ASSIGNMENT (event), ACTIVATION
------------------------------------------------------------
!create s1 : Session
!set s1.id := 'S1'
!insert (s1, u1) into ActiveUser

!insert (u1, rEng) into UserAssignment
!create asg1 : Assignment
!insert (u1,   asg1) into AssignmentUser
!insert (rEng, asg1) into AssignmentRole
!insert (t0,   asg1) into AssignmentSnapshot

!create act1 : Activation
!insert (s1,   act1) into ActivationSession
!insert (rEng, act1) into ActivationRole
!insert (t1,   act1) into ActivationSnapshot

------------------------------------------------------------
-- 8) CHECK + QUERY
------------------------------------------------------------
check
-- Expect: structure OK; all invariants OK

-- GRANT: both userLoc (Leaf) and objLoc (Leaf) satisfy pRoot via ancestors to Root
? s1.checkAccess(aRead, resA, t1)
-- -> true
