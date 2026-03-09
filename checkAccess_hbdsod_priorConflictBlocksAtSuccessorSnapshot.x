-- HistoryBasedDSOD: conflicting prior action at t1 blocks at t2.

reset
-- Locations
!create L_root : Location
!create L_leaf : Location
!insert (L_root, L_leaf) into LocationHierarchy

-- Actions + mutual exclusion
!create aApprove : Action
!set aApprove.name := 'approve'
!create aReview  : Action
!set aReview.name := 'review'
!create aRead    : Action
!set aRead.name := 'read'
!insert (aApprove, aReview) into MutuallyExclusiveActions
!insert (aReview,  aApprove) into MutuallyExclusiveActions

-- Resource at Leaf with HB-DSOD on
!create resA : Resource
!set resA.name := 'DocA'
!set resA.resourceBasedDynamicSeparationOfDuty := false
!set resA.historyBasedDynamicSeparationOfDuty := true
!insert (resA, aApprove) into ResourceAction
!insert (resA, aReview)  into ResourceAction
!insert (resA, aRead)    into ResourceAction
!insert (resA, L_leaf)   into ResourceLocation

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

-- Permission (approve/review/read), location-qualified
!create pBoth : Permission
!set pBoth.name := 'pBoth'
!set pBoth.maxRoles := 10
!set pBoth.maxSessions := 10
!insert (pBoth, resA)     into PermissionResource
!insert (pBoth, aApprove) into PermissionAction
!insert (pBoth, aReview)  into PermissionAction
!insert (pBoth, aRead)    into PermissionAction
!insert (pBoth, L_leaf)   into PermissionRoleLocation
!insert (pBoth, L_leaf)   into PermissionObjectLocation
!insert (pBoth, L_root)   into PermissionRoleLocation
!insert (pBoth, L_root)   into PermissionObjectLocation
!insert (rEng,  pBoth)    into PermissionAssignment

-- User at Leaf for both t1 and t2; t1->t2 chain
!create u1 : User
!set u1.name := 'U1'
!set u1.maxRoles := 5
!set u1.maxRolesRespectingHierarchy := false
!set u1.maxSessions := 5
!create t1 : Snapshot
!create t2 : Snapshot
!insert (t1, t2) into PredSuccSnapshot
!insert (t1, u1) into SnapshotUser  

!create ua1 : UserAt
!insert (u1, ua1)     into UserAtUser
!insert (L_leaf, ua1) into UserAtLocation
!insert (t1, ua1)     into UserAtSnapshot
!create ua2 : UserAt
!insert (u1, ua2)     into UserAtUser
!insert (L_leaf, ua2) into UserAtLocation
!insert (t2, ua2)     into UserAtSnapshot

-- Session + activations at both snapshots
!create s1 : Session
!set s1.id := 'S1'
!insert (s1, u1) into ActiveUser

!insert (u1, rEng) into UserAssignment
!create asg1 : Assignment
!insert (u1, asg1)   into AssignmentUser
!insert (rEng, asg1) into AssignmentRole
!insert (t1, asg1)   into AssignmentSnapshot

!create act1 : Activation
!insert (s1, act1)   into ActivationSession
!insert (rEng, act1) into ActivationRole
!insert (t1, act1)   into ActivationSnapshot
!create act2 : Activation
!insert (s1, act2)   into ActivationSession
!insert (rEng, act2) into ActivationRole
!insert (t2, act2)   into ActivationSnapshot

check
-- Expect: structure OK; all invariants OK

-- APPROVE: No conflicting access yet
? s1.checkAccess(aApprove, resA, t1)

-- APPROVE: Non-conflicting action
? s1.checkAccess(aRead, resA, t1)

-- Record a prior conflicting action at t1
!create acc1 : Access
!set acc1.id := 'ACC1'
!insert (s1,     acc1) into ActiveAccess
!insert (resA,   acc1) into AccessResource
!insert (aReview,acc1) into ActionAccess
!insert (t1,     acc1) into AccessSnapshot

-- DENY at t2 (HB-DSOD sees t1 as predecessor)
? s1.checkAccess(aApprove, resA, t2)
-- -> false

-- Non-conflicting still allowed at t2
? s1.checkAccess(aRead, resA, t2)
-- -> true
