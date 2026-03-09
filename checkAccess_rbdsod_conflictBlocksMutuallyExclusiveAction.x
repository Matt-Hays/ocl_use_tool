-- Resource enforced RBDSOD.
-- 1st == GRANT: No conflict
-- 2nd == DENY: Mutually exclusive actions attempted.

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

-- Resource at Leaf with RB-DSOD on
!create resA : Resource
!set resA.name := 'DocA'
!set resA.resourceBasedDynamicSeparationOfDuty := true
!set resA.historyBasedDynamicSeparationOfDuty := false
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

-- Single permission that includes both mutually-exclusive actions (+ read)
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
-- Satisfy Location<->Permission multiplicity for Root as well (same permission is fine)
!insert (pBoth, L_root)   into PermissionRoleLocation
!insert (pBoth, L_root)   into PermissionObjectLocation
!insert (rEng,  pBoth)    into PermissionAssignment

-- User @ Leaf at t1
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

-- Session + activation
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

!insert (t1, u1) into SnapshotUser

check
-- Expect: all invariants OK

-- GRANT (no conflict recorded yet)
? s1.checkAccess(aApprove, resA, t1)
-- -> true

-- Record a conflicting action at the same snapshot
!create acc1 : Access
!set acc1.id := 'ACC1'
!insert (s1, acc1)     into ActiveAccess
!insert (resA, acc1)   into AccessResource
!insert (aReview, acc1) into ActionAccess
!insert (t1, acc1)     into AccessSnapshot

-- DENY now (RB-DSOD blocks the mutually-exclusive action)
? s1.checkAccess(aApprove, resA, t1)
-- -> false

-- Non-conflicting action still allowed
? s1.checkAccess(aRead, resA, t1)
-- -> true
