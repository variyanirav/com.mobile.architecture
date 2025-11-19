# C4 Model Overview

This directory contains the C4 architecture diagrams for the Mobile Architecture project.

## What is C4?

C4 stands for **Context, Containers, Components, Code** - a hierarchical approach to software architecture diagrams created by Simon Brown.

### The 4 Levels:

```
Level 1: Context    ──▶  Zoom Level: 30,000 feet
Level 2: Containers ──▶  Zoom Level: 10,000 feet  
Level 3: Components ──▶  Zoom Level: 1,000 feet
Level 4: Code       ──▶  Zoom Level: Ground level
```

## Our Diagrams

### 📄 [Context Diagram](context.md) - Level 1
**Audience:** Everyone (stakeholders, management, developers)

**Shows:**
- The system as a black box
- Users who interact with it
- External systems it connects to

**Use for:**
- Executive presentations
- Project proposals
- High-level system overview

**Key Questions Answered:**
- Who uses the system?
- What other systems does it talk to?
- What are the system boundaries?

---

### 📄 [Container Diagram](container.md) - Level 2
**Audience:** Technical team, architects, senior developers

**Shows:**
- Technology choices (Flutter, SQLite, REST API)
- How containers communicate
- Data flow between containers

**Use for:**
- Technical architecture reviews
- Technology stack decisions
- DevOps and deployment planning

**Key Questions Answered:**
- What technology stack are we using?
- How do components communicate?
- Where is data stored?
- What protocols are used?

---

## Why C4?

### Benefits:
✅ **Standardized** - Industry-recognized notation  
✅ **Hierarchical** - Different zoom levels for different audiences  
✅ **Communicative** - Easy to understand  
✅ **Up-to-date** - Can be generated from code  
✅ **Scalable** - Works for small and large systems  

### Comparison with Other Approaches:

| Approach | Pros | Cons |
|----------|------|------|
| **UML** | Very detailed | Too complex, hard to maintain |
| **Boxes & Arrows** | Simple | Inconsistent, ambiguous |
| **C4** | Balanced, clear hierarchy | Requires discipline to maintain |

---

## How to Use These Diagrams

### 1. For Presentations
- **Exec/Business:** Use Context diagram
- **Technical Review:** Use Container diagram
- **Architecture Deep Dive:** Use both

### 2. For Documentation
- Link from README.md
- Include in architecture decision records (ADRs)
- Reference in onboarding docs

### 3. For Planning
- Use Context to discuss integrations
- Use Container to plan infrastructure
- Update after major architectural changes

---

## Tooling

You can generate C4 diagrams using:

1. **Structurizr** - DSL and visualization tool
2. **PlantUML** - C4 extension
3. **Mermaid** - Built into GitHub (see diagrams)
4. **draw.io** - Manual drawing
5. **Markdown + ASCII** - What we use here

---

## Maintenance

### When to Update:

✏️ **Context Diagram:**
- Adding/removing external systems
- Adding new user types
- Changing system boundaries

✏️ **Container Diagram:**
- Adding new technology
- Changing communication protocols
- Adding/removing data stores
- Deployment model changes

### Review Frequency:
- **Context:** Every 6 months or major release
- **Container:** Every sprint/feature that touches architecture

---

## Next Steps

### Level 3: Component Diagram (Future)
Would show internal components of each container:
- Presentation: Pages, Widgets, BLoCs
- Domain: Entities, Use Cases, Repositories
- Data: API Clients, Data Sources, Cache

### Level 4: Code Diagram (Rarely Used)
Would show class diagrams - usually IDE-generated.

---

## References

- **C4 Model Official:** [c4model.com](https://c4model.com/)
- **Simon Brown (Creator):** [@simonbrown](https://twitter.com/simonbrown)
- **Book:** "Software Architecture for Developers" by Simon Brown
- **Examples:** [c4model.com/examples](https://c4model.com/examples)

---

**Project:** Mobile Architecture  
**Created:** Day 2 - November 19, 2025  
**Diagrams:** 2 (Context + Container)  
**Status:** Complete ✅
