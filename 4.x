-- Role assigned, but no ACTIVATION at the queried SNAPSHOT.

reset
-- Locations
!create L_root : Location
!create L_leaf : Location
!insert (L_root, L_leaf) into LocationHierarchy

-- Actions
!create aRead : Action
!set aRead.name := 'read'

-- Resource at Leaf
!create resA : Resource
!set resA.name := 'DocA'
!set resA.resourceBasedDynamicSeparationOfDuty := false
!set resA.historyBasedDynamicSeparationOfDuty := false
!insert (resA, aRead)  into ResourceAction
!insert (resA, L_leaf) into ResourceLocation

-- Role + multiplicities
!create rEng : Role
!set rEng.name := 'Engineer'
!set rEng.maxMembers := 10
!set rEng.maxJuniors := 10
!set rEng.exclusiveJuniorsAllowed := false
!insert (rEng, L_root) into RoleAssignLocation
!insert (rEng, L_leaf) into RoleAssignLocation
!insert (rEng, L_root) into RoleActivateLocation
!insert (rEng, L_leaf) into RoleActivateLocation

-- Permission (roleLoc=objLoc=Leaf)
!create pLeaf : Permission
!set pLeaf.name := 'pLeaf'
!set pLeaf.maxRoles := 10
!set pLeaf.maxSessions := 10
!insert (pLeaf, resA)   into PermissionResource
!insert (pLeaf, aRead)  into PermissionAction
!insert (pLeaf, L_leaf) into PermissionRoleLocation
!insert (pLeaf, L_leaf) into PermissionObjectLocation
!insert (rEng, pLeaf)   into PermissionAssignment

-- User + snapshots
!create u1 : User
!set u1.name := 'U1'
!set u1.maxRoles := 5
!set u1.maxRolesRespectingHierarchy := false
!set u1.maxSessions := 5
!create t0 : Snapshot
!create t1 : Snapshot
!insert (t0, t1) into PredSuccSnapshot

!create ua0 : UserAt
!insert (u1, ua0)     into UserAtUser
!insert (L_leaf, ua0) into UserAtLocation
!insert (t0, ua0)     into UserAtSnapshot

!create ua1 : UserAt
!insert (u1, ua1)     into UserAtUser
!insert (L_leaf, ua1) into UserAtLocation
!insert (t1, ua1)     into UserAtSnapshot

-- Session (no activation at t1)
!create s1 : Session
!set s1.id := 'S1'
!insert (s1, u1) into ActiveUser

-- Assignment only
!insert (u1, rEng) into UserAssignment
!create asg1 : Assignment
!insert (u1, asg1)   into AssignmentUser
!insert (rEng, asg1) into AssignmentRole
!insert (t0, asg1)   into AssignmentSnapshot

-- Binder permission to satisfy Location<->Permission multiplicities for ROOT
!create pRootBinder : Permission
!set pRootBinder.name := 'pRootBinder'
!set pRootBinder.maxRoles := 10
!set pRootBinder.maxSessions := 10

-- Every Permission must have >=1 resource and >=1 action; reuse resA/aRead
!insert (pRootBinder, resA)  into PermissionResource
!insert (pRootBinder, aRead) into PermissionAction

-- Point it at ROOT on both sides
!insert (pRootBinder, L_root) into PermissionRoleLocation
!insert (pRootBinder, L_root) into PermissionObjectLocation

!insert (t1, u1) into SnapshotUser

check
-- Expect: all invariants OK

-- DENY: no active role at t1
? s1.checkAccess(aRead, resA, t1)
-- -> false
