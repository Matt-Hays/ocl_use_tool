-- User location mismatch: DENY
-- User at ROOT, premission requires LEAF (roleLoc=LEAF,objLoc=LEAF). Resource is at LEAF. Active role exists.

reset
-- Locations
!create L_root : Location
!create L_leaf : Location
!insert (L_root, L_leaf) into LocationHierarchy

-- Actions
!create aRead : Action
!set aRead.name := 'read'
!create aApprove : Action
!set aApprove.name := 'approve'

-- Resource at Leaf supports both
!create resA : Resource
!set resA.name := 'DocA'
!set resA.resourceBasedDynamicSeparationOfDuty := false
!set resA.historyBasedDynamicSeparationOfDuty := false
!insert (resA, aRead)    into ResourceAction
!insert (resA, aApprove) into ResourceAction
!insert (resA, L_leaf)   into ResourceLocation

-- Role covers both locations for assign/activate multiplicities
!create rEng : Role
!set rEng.name := 'Engineer'
!set rEng.maxMembers := 10
!set rEng.maxJuniors := 10
!set rEng.exclusiveJuniorsAllowed := false
!insert (rEng, L_root) into RoleAssignLocation
!insert (rEng, L_leaf) into RoleAssignLocation
!insert (rEng, L_root) into RoleActivateLocation
!insert (rEng, L_leaf) into RoleActivateLocation

-- Permissions:
-- pLeaf: the only permission that matches (read on resA, roleLoc=objLoc=Leaf)
!create pLeaf : Permission
!set pLeaf.name := 'pLeaf'
!set pLeaf.maxRoles := 10
!set pLeaf.maxSessions := 10
!insert (pLeaf, resA)   into PermissionResource
!insert (pLeaf, aRead)  into PermissionAction
!insert (pLeaf, L_leaf) into PermissionRoleLocation
!insert (pLeaf, L_leaf) into PermissionObjectLocation

-- pRootDummy: satisfies Location<->Permission multiplicities for Root but doesn't match our probe
!create pRootDummy : Permission
!set pRootDummy.name := 'pRootDummy'
!set pRootDummy.maxRoles := 10
!set pRootDummy.maxSessions := 10
!insert (pRootDummy, resA)     into PermissionResource
!insert (pRootDummy, aApprove) into PermissionAction
!insert (pRootDummy, L_root)   into PermissionRoleLocation
!insert (pRootDummy, L_root)   into PermissionObjectLocation

-- Bind perms to role
!insert (rEng, pLeaf)      into PermissionAssignment
!insert (rEng, pRootDummy) into PermissionAssignment

-- User, snapshots, locations (exactly one UserAt per snapshot)
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
!insert (L_root, ua0) into UserAtLocation
!insert (t0, ua0)     into UserAtSnapshot

!create ua1 : UserAt
!insert (u1, ua1)     into UserAtUser
!insert (L_root, ua1) into UserAtLocation
!insert (t1, ua1)     into UserAtSnapshot

-- Session + assignment + activation (valid)
!create s1 : Session
!set s1.id := 'S1'
!insert (s1, u1) into ActiveUser

!insert (u1, rEng) into UserAssignment
!create asg1 : Assignment
!insert (u1, asg1)   into AssignmentUser
!insert (rEng, asg1) into AssignmentRole
!insert (t0, asg1)   into AssignmentSnapshot

!create act1 : Activation
!insert (s1, act1)   into ActivationSession
!insert (rEng, act1) into ActivationRole
!insert (t1, act1)   into ActivationSnapshot

check
-- Expect: all invariants OK

-- DENY: user at Root, perm requires Leaf (no ancestor of Root equals Leaf)
? s1.checkAccess(aRead, resA, t1)
-- -> false
