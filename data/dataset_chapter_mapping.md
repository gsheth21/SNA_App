# SNA App — Dataset & Chapter Compatibility Reference

## 1. Chapter → Dataset Type Compatibility

Based on the book's QMD chapter files. Four dataset types: **UN** (Undirected Unweighted), **UW** (Undirected Weighted), **DN** (Directed Unweighted), **DW** (Directed Weighted).

| Chapter | UN | UW | DN | DW | Notes |
|---------|----|----|----|----|-------|
| **Networks** | ✅ | ✅ | ✅ | ✅ | All types work. Node attr visualization requires vertex attributes. |
| **Connectivity** | ✅ | ✅ | ✅ | ✅ | All types work. bridges/cutpoints auto-converts to undirected internally. |
| **Centrality** | ✅ | ✅ | ✅ | ✅ | All types work. Correlation-with-attrs section needs numerical vertex attrs. |
| **Communities** | ✅ | ✅ | ❌ | ❌ | `cliques()` and `cluster_louvain()` hard-fail on directed graphs. |
| **Assortativity** | ✅ | ✅ | ✅ | ✅ | All types work structurally, but full chapter needs categorical vertex attrs. |
| **Roles** | ✅ | ❌ | ✅ | ❌ | Equivalence is topology-only; weights are irrelevant and misleading. |
| **Simulation** | —  | —  | —  | —  | Generates its own networks; uploaded dataset type is irrelevant. |

---

## 2. Dataset Inventory

| File | Object(s) | Type | Nodes | Edges | Vertex Attrs (embedded) | Edge Attrs |
|------|-----------|------|-------|-------|--------------------------|------------|
| `moreno.rda` | `moreno` | UN | 33 | 46 | gender (n), vertex.names (n) | — |
| `ifm.rda` | `ifm` | UN | 16 | 20 | seats (n), wealth (n), vertex.names (c) | — |
| `sampson.rda` | `sampson` | UN | 18 | 60 | cloisterville (l), group (c), vertex.names (c) | — |
| `github.rda` | `github` | UW | 174 | 890 | name (c), component (n) | weight (n) |
| `drugnet.rda` | `drug_connect` | DN | 193 | 323 | name (c), ethnicity (n), gender (n) | — |
| `drugnet.rda` | `drugnet` | DN | 293 | 337 | name (c), ethnicity (n), gender (n) | — |
| `hi_tech.rda` | `htf` | DN | 21 | 102 | name (c), age (n), tenure (n), level (n), dept (n) | — |
| `hi_tech.rda` | `hta` | DN | 21 | 190 | name (c), age (n), tenure (n), level (n), dept (n) | — |
| `hi_tech.rda` | `htr` | DN | 21 | 20 | name (c), age (n), tenure (n), level (n), dept (n) | — |
| `tradenets.rda` | `c` | DN | 24 | 307 | name (c) | — |
| `tradenets.rda` | `d` | DN | 24 | 369 | name (c) | — |
| `tradenets.rda` | `f` | DN | 24 | 307 | name (c) | — |
| `tradenets.rda` | `m` | DN | 24 | 135 | name (c) | — |
| `tradenets.rda` | `mg` | DW | 24 | 310 | name (c) | weight (n) |

**Notes on drugnet.rda**: Loading this file produces 22 R objects due to old igraph serialization format. Only `drug_connect` and `drugnet` are actual igraph objects; the rest are internal storage artifacts. `drug_connect` is the largest connected component of `drugnet`.

**Notes on tradenets.rda**: `trade_attr` is a detached data frame (POP_GROWTH, GNP, SCHOOLS, ENERGY) NOT embedded in any igraph object. Would need to be joined in before assortativity/centrality correlation features work.

**Attr types**: (n) = numeric, (c) = character, (l) = logical

---

## 3. Dataset → Chapter Mapping

⭐ = book's own dataset for that chapter | ⚠️ = partial/limited | ❌ = incompatible

### Networks
All datasets work. The **Networks** chapter covers undirected, directed, unweighted, weighted, matrices, and node/edge attribute visualization.
- `htf` ⭐ — DN with rich attrs (dept, tenure, level) — used for all visualization examples
- `moreno` — UN, good small example
- `ifm` — UN with vertex.names
- `sampson` — UN with vertex.names
- `github` — only UW dataset; demonstrates edge weights
- `drug_connect` / `drugnet` — DN
- `c`, `d`, `f`, `m` — DN (trade flows)
- `mg` — only DW dataset
- `hta`, `htr` — DN

### Connectivity
All datasets work. Key features: components, paths, distances, diameter, bridges/cutpoints, reachability.
- `moreno` ⭐ — book dataset; has 2 components (31+2 nodes), perfect for components/reachability
- `drugnet` — full network with multiple components (better than drug_connect for this chapter)
- `drug_connect` — single large connected component; good for paths/distances
- `ifm` — Pucci is an isolate; interesting for reachability
- `sampson` — dense connected network
- `github` — large network (174 nodes) for distance/diameter exploration
- `htf`, `hta` — DN, directed paths
- `c`, `d`, `f`, `m`, `mg` — trade networks, directed

**Avoid `htr`** for this chapter — only 20 edges, very sparse.

### Centrality
All dataset types work. Key features: degree, closeness, betweenness, eigenvector. "Benefits of centrality" correlation section needs numerical vertex attrs.
- `ifm` ⭐ — book dataset; centrality correlated with `seats` (political) and `wealth` (economic)
- `htf` / `hta` — DN; `age`, `tenure` for numerical correlation; `dept`, `level` for categorical
- `drug_connect` — DN; `ethnicity`, `gender` for correlation
- `moreno` — UN; `gender` limited for correlation but works
- `sampson` — UN; `group`/`cloisterville` limited (no numerical attrs for meaningful correlation)
- `github` — UW; weighted centrality; `component` for correlation
- `c`, `d`, `f`, `m`, `mg` — no vertex attrs beyond name; correlation section won't work

**Avoid `htr`** — too sparse for meaningful centrality differences.

### Communities
**UN and UW only**. `cliques()` and `cluster_louvain()` hard-fail on directed graphs. Key features: cliques, k-core, community detection (Louvain/edge-betweenness/walktrap), modularity by attribute.
- `sampson` ⭐ — book dataset; `cloisterville` for modularity-by-attribute; `group` for comparing detection vs. observed groups
- `moreno` — UN; `gender` for modularity-by-attribute
- `ifm` — UN; `seats`/`wealth` usable; small so cliques are limited
- `github` — UW; `component` as factor for modularity-by-attribute; large network for interesting community structure
- All DN/DW datasets (`drug_connect`, `drugnet`, `htf`, `hta`, `htr`, `c`, `d`, `f`, `m`, `mg`) — ❌ incompatible

### Assortativity
All types work structurally. Full chapter needs **categorical vertex attrs** (nominal assortativity) and **numerical vertex attrs** (continuous assortativity). Degree assortativity always available regardless.
- `drug_connect` ⭐ — book dataset; `ethnicity` + `gender` for nominal assortativity; edge homophily by group analysis
- `htf` / `hta` — richest for assortativity: nominal (`dept`, `level`) + numerical (`age`, `tenure`) both work
- `moreno` — `gender` for nominal assortativity
- `sampson` — `group` and `cloisterville` for nominal assortativity
- `ifm` — `wealth`/`seats` for numerical/continuous assortativity only (no categorical attr)
- `github` — `component` for numerical assortativity
- `c`, `d`, `f`, `m`, `mg` — degree assortativity only (no vertex attrs beyond name)
- `drugnet` — same as drug_connect

### Roles
**UN and DN only** (topology-based; weights irrelevant). Key features: structural, automorphic, regular equivalence.
- `drug_connect` / `drugnet` — DN; directed equivalence meaningful
- `htf` / `hta` — DN; three relation types (advice/friendship/reporting) make role comparison especially meaningful across `hta`, `htf`, `htr`
- `htr` — DN; very sparse (20 edges) but meaningful reporting hierarchy
- `moreno` — UN
- `ifm` — UN
- `sampson` — UN
- `c`, `d`, `f`, `m` — DN (trade flows)
- `github` — ❌ UW (weights don't fit)
- `mg` — ❌ DW (weights don't fit)

### Simulation
Dataset irrelevant — chapter generates its own networks (empty, full, star, ring, tree, lattice, Erdős–Rényi, Watts-Strogatz, Barabási-Albert).

---

## 4. Quick Reference Grid

| Dataset | Networks | Connectivity | Centrality | Communities | Assortativity | Roles |
|---------|:--------:|:------------:|:----------:|:-----------:|:-------------:|:-----:|
| `moreno` | ✅ | ✅ ⭐ | ✅ | ✅ | ✅ | ✅ |
| `ifm` | ✅ | ✅ | ✅ ⭐ | ✅ | ✅ | ✅ |
| `sampson` | ✅ | ✅ | ✅ | ✅ ⭐ | ✅ | ✅ |
| `github` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `drug_connect` | ✅ | ✅ | ✅ | ❌ | ✅ ⭐ | ✅ |
| `drugnet` | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| `htf` | ✅ ⭐ | ✅ | ✅ | ❌ | ✅ | ✅ |
| `hta` | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| `htr` | ✅ | ⚠️ sparse | ⚠️ sparse | ❌ | ⚠️ sparse | ✅ |
| `c` / `d` / `f` / `m` | ✅ | ✅ | ✅ | ❌ | ⚠️ no attrs | ✅ |
| `mg` | ✅ | ✅ | ✅ | ❌ | ⚠️ no attrs | ❌ |

---

## 5. Coverage Gaps

- **No DW dataset with vertex attributes** — `mg` is the only DW but has only `name`. Assortativity and centrality correlation sections won't fully work for DW.
- **`trade_attr` detached** — `tradenets.rda` country attributes (GNP, SCHOOLS, etc.) are in a separate data frame, not embedded in igraph objects. Need joining logic in the app.
- **Communities has no DN/DW datasets** — by mathematical necessity (`cliques()` undefined on directed graphs).
