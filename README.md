# LRBAC in USE — Repository Overview

A compact, validated **Location‑Aware RBAC (LRBAC)** model for the **USE** (UML‑based Specification Environment) tool, plus a set of small, single‑purpose scenarios. This README is intentionally brief and defers details to the accompanying write‑up.

---

**Full write‑up:** [RBAC_Writeup___LRBAC.pdf](RBAC_Writeup___LRBAC.pdf). 

## What’s here

- [LRBAC.use](LRBAC.use) — the model specification (classes, associations, invariants, helper ops)
- `checkAccess... .x` — self‑contained scenarios; each resets the universe, builds a minimal setup, and issues a small number of queries (with expected outcomes commented inline)
- [RBAC_Writeup___LRBAC.pdf](RBAC_Writeup___LRBAC.pdf) — full design & validation write‑up

> Scenarios are independent. Run them one at a time. Each execution will resets the environment.

---

## Quick start (high‑level)

1) Open the model (`LRBAC.use`) in USE.  
2) Execute any one of the scenario files (`checkAccess... .x`).  
3) Inspect the final queries in the scenario; expected results are noted in comments.

> Please refer to USE tooling documentation for specific USE commands. Execution result examples are shown and discussed in the [full write-up](RBAC_Writeup___LRBAC.pdf).

---

## Documentation

For the complete rationale, diagrams, and validation evidence (including DSOD variants and location semantics), read:

- [RBAC_Writeup___LRBAC.pdf](RBAC_Writeup___LRBAC.pdf)

