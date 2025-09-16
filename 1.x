reset
-- Locations: Root > Leaf
!create L_root : Location
!set L_root.name := 'Root'
!create L_leaf : Location
!set L_leaf.name := 'Leaf'
!insert (L_root, L_leaf) into LocationHierarchy    

-- Actions
!create aRead : Action
!set aRead.name := 'read'
!create aApprove : Action
!set aApprove.name := 'approve'

-- Resource at Leaf (supports both actions)
!create resA : Resource
!set resA.name := 'DocA'
!set resA.resourceBasedDynamicSeparationOfDuty := false
!set resA.historyBasedDynamicSeparationOfDuty := false
!insert (resA, aRead)    into ResourceAction
!insert (resA, aApprove) into ResourceAction
!insert (resA, L_leaf)   into ResourceLocation

-- One role; make it "the one" for both locations (satisfies RoleAssign/Activate *per* Location)
!create rEng : Role
!set rEng.name := 'Engineer'
!set rEng.maxMembers := 10
!set rEng.maxJuniors := 10
!set rEng.exclusiveJuniorsAllowed := false
!insert (rEng, L_root) into RoleAssignLocation
!insert (rEng, L_leaf) into RoleAssignLocation
!insert (rEng, L_root) into RoleActivateLocation
!insert (rEng, L_leaf) into RoleActivateLocation

-- Two permissions, each "owns" exactly one Location for both roleLoc & objLoc
-- pRoot: (roleLoc=objLoc=Root), allows ancestor-based grant when user at Leaf & object at Leaf
!create pRoot : Permission
!set pRoot.name := 'pRoot'
!set pRoot.maxRoles := 10
!set pRoot.maxSessions := 10
!insert (pRoot, resA)   into PermissionResource
!insert (pRoot, aRead)  into PermissionAction
!insert (pRoot, L_root) into PermissionRoleLocation
!insert (pRoot, L_root) into PermissionObjectLocation

-- pLeaf: (roleLoc=objLoc=Leaf), exact-location grant
!create pLeaf : Permission
!set pLeaf.name := 'pLeaf'
!set pLeaf.maxRoles := 10
!set pLeaf.maxSessions := 10
!insert (pLeaf, resA)     into PermissionResource
!insert (pLeaf, aApprove) into PermissionAction
!insert (pLeaf, L_leaf)   into PermissionRoleLocation
!insert (pLeaf, L_leaf)   into PermissionObjectLocation

-- Bind perms to role
!insert (rEng, pRoot) into PermissionAssignment
!insert (rEng, pLeaf) into PermissionAssignment

-- User + Snapshots (EXACTLY one SnapshotUser link by model multiplicity)
!create u1 : User
!set u1.name := 'U1'
!set u1.maxRoles := 5
!set u1.maxRolesRespectingHierarchy := false
!set u1.maxSessions := 5
!create t0 : Snapshot
!create t1 : Snapshot
!insert (t0, t1) into PredSuccSnapshot
!insert (t0, u1) into SnapshotUser

-- Exactly one UserAt per (user, snapshot) (your invariant)
!create ua0 : UserAt
!insert (u1,     ua0) into UserAtUser
!insert (L_leaf, ua0) into UserAtLocation
!insert (t0,     ua0) into UserAtSnapshot
!create ua1 : UserAt
!insert (u1,     ua1) into UserAtUser
!insert (L_leaf, ua1) into UserAtLocation
!insert (t1,     ua1) into UserAtSnapshot

-- Session + Activation at t1
!create s1 : Session
!set s1.id := 'S1'
!insert (s1, u1) into ActiveUser

-- assignment-time event (precise check)
!insert (u1, rEng) into UserAssignment
!create asg1 : Assignment
!insert (u1,   asg1) into AssignmentUser
!insert (rEng, asg1) into AssignmentRole
!insert (t0,   asg1) into AssignmentSnapshot

!create act1 : Activation
!insert (s1,   act1) into ActivationSession
!insert (rEng, act1) into ActivationRole
!insert (t1,   act1) into ActivationSnapshot

check
-- Expect: structure OK; all invariants OK

-- GRANT #1: ancestor-based (user at Leaf, object at Leaf, perm at Root)
? s1.checkAccess(aRead, resA, t1)
-- -> true

-- GRANT #2: exact-location (Leaf for both)
? s1.checkAccess(aApprove, resA, t1)
-- -> true
