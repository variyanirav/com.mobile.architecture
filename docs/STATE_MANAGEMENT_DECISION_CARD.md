# State Management Quick Decision Card

**Use this card for quick decisions. For detailed analysis, see [State Management Decision Framework](./state-management-decision-framework.md)**

---

## 🚦 Critical Filters (Must Answer YES to All for That Pattern)

### Choose Provider If ALL of These Are TRUE:
- [ ] DAU < 1,000 users
- [ ] No regulated industry (not finance/healthcare)
- [ ] Simple business logic (CRUD only)
- [ ] Project lifespan < 6 months
- [ ] Performance not critical (no real-time features)
- [ ] Test coverage < 50% acceptable

**If ANY are FALSE → Consider Riverpod or BLoC**

---

### Choose Riverpod If ANY of These Are TRUE:
- [ ] DAU 1K - 100K users
- [ ] Need high performance (60 FPS, animations)
- [ ] Complex dependencies between features
- [ ] Project lifespan 6 months - 3 years
- [ ] Test coverage 70%+ required
- [ ] Want modern best practices

**Also choose if migrating from Provider due to complexity**

---

### Choose BLoC If ANY of These Are TRUE:
- [ ] **Regulated industry (finance, healthcare, insurance)**
- [ ] **Need audit trails for compliance**
- [ ] DAU > 10K users
- [ ] Complex state machines or workflows
- [ ] Project lifespan > 2 years
- [ ] Test coverage > 80% required
- [ ] Multiple team members need strict patterns

**RED FLAGS requiring BLoC:**
- **Banking/fintech apps** → BLoC MANDATORY
- **Healthcare/medical** → BLoC MANDATORY
- **Legal/compliance-heavy** → BLoC MANDATORY

---

## 📊 Decision Scorecard

Rate each factor (0-5):

| Factor | Weight | Provider | Riverpod | BLoC |
|--------|--------|----------|----------|------|
| **Performance Critical** | 3x | 2 | 5 | 4 |
| **Complexity** | 3x | 2 | 4 | 5 |
| **DAU Scale** | 2x | 3 | 5 | 5 |
| **Test Coverage** | 2x | 3 | 5 | 5 |
| **Lifespan** | 2x | 3 | 5 | 5 |
| **Compliance** | 5x | 1 | 2 | 5 |
| **Time to Market** | 1x | 5 | 3 | 2 |
| **Team Experience** | 1x | 5 | 3 | 2 |

**How to Score:**
1. Multiply each score by weight
2. Sum totals for each pattern
3. Highest score = recommended pattern

**Example for Banking App:**
- Compliance (5x5) = 25 for BLoC
- **BLoC wins** due to compliance alone!

---

## 🎯 Reality Check Examples

### ❌ WRONG Decisions (Based on Team Size)

**Case 1: Solo Dev, Banking App**
- ~~Team size = 1 → Provider~~ ❌
- **Correct:** BLoC (compliance required)

**Case 2: 10 Devs, Simple CMS**
- ~~Team size = 10 → BLoC~~ ❌
- **Correct:** Provider (simple CRUD)

**Case 3: 3 Devs, Trading Platform**
- ~~Team size = 3 → Provider~~ ❌
- **Correct:** BLoC (performance + compliance)

---

### ✅ CORRECT Decisions (Based on Technical Needs)

**Case 1: E-commerce, 50K DAU**
- **Technical:** High performance, complex state
- **Correct:** Riverpod
- **Team size:** Irrelevant

**Case 2: To-do App, 100 Users**
- **Technical:** Simple CRUD, no scale
- **Correct:** Provider
- **Team size:** Irrelevant

**Case 3: Insurance Portal, Regulated**
- **Technical:** Compliance + audit trails
- **Correct:** BLoC
- **Team size:** Irrelevant

---

## 🔴 STOP! Critical Questions

Before finalizing your choice, answer these:

### 1. Is This a Regulated Industry?
- **YES** → BLoC (mandatory)
- **NO** → Continue

### 2. Do You Need Audit Trails?
- **YES** → BLoC (only option)
- **NO** → Continue

### 3. Expected DAU?
- **< 1K** → Any pattern
- **1K - 10K** → Provider or Riverpod
- **10K+** → Riverpod or BLoC

### 4. Performance Critical?
- **YES** (60 FPS, real-time) → Riverpod
- **NO** → Continue

### 5. Project Lifespan?
- **< 6 months** → Provider
- **6 months - 2 years** → Riverpod
- **> 2 years** → BLoC or Riverpod

---

## 📈 Migration Paths

### Provider → Riverpod
**When:** Complexity outgrows Provider
**Time:** 2-4 weeks
**Difficulty:** Medium

### Provider → BLoC
**When:** Need compliance or complex workflows
**Time:** 4-8 weeks
**Difficulty:** High

### Riverpod → BLoC
**When:** Regulatory requirements added
**Time:** 3-6 weeks
**Difficulty:** Medium

---

## 🎓 Summary

### What Matters:
1. ✅ Technical complexity
2. ✅ Performance requirements
3. ✅ Daily active users
4. ✅ Compliance needs
5. ✅ Project lifespan

### What Doesn't Matter (as primary factor):
6. ⚠️ Team size (secondary)
7. ⚠️ Number of developers (secondary)
8. ⚠️ Team structure (secondary)

---

## 🚀 Quick Start

### New Project Checklist:

```
[ ] Identify if regulated industry
[ ] Estimate DAU in 6 months
[ ] Assess complexity (simple CRUD vs workflows)
[ ] Define performance requirements
[ ] Plan project lifespan
[ ] Set test coverage goals
[ ] THEN choose state management pattern
```

**Don't start with team size!**

---

## 📚 Resources

- [Full Technical Analysis](./state-management-decision-framework.md)
- [Why Team Size Doesn't Matter](./WHY_TEAM_SIZE_DOESNT_MATTER.md)
- [Pattern Comparison](./state-management-comparison.md)
- [Visual Guide](./state-management-visual-comparison.md)

---

**Last Updated:** 2026-01-11  
**Print this card and keep it visible during architecture decisions!**
