## 👋 Hi, I’m Naresh Jagadeesan

**C++ Software developer** with a strong bias toward low-level engineering: **networking, concurrency, storage, and protocol design**.

I love building things close to the metal: servers, tools, interpreters & infrastructure in **modern C++**.

---

## 🔧 Core Interests

* Modern C++, duh
* Networking & distributed systems
* Storage engines & protocol implementations
* OS adjacent tooling
* Re-implementing foundational tools to understand them deeply

---

## ⭐ Noteworthy Projects

### **Git**

🔗 [https://github.com/Infinage/cpp-experiments/tree/main/cgit](https://github.com/Infinage/cpp-experiments/tree/main/cgit)

> Re-implementation of core Git concepts in C++

* Object storage (blobs, trees, commits)
* Content-addressable storage
* Index & basic plumbing commands
* Focus on correctness, file formats, and internals

➡️ *Primary learning project for VCS internals*

---

### **Ctorrent**

🔗 [https://github.com/Infinage/cpp-experiments/tree/main/torrent](https://github.com/Infinage/cpp-experiments/tree/main/torrent)

> A BitTorrent client written in C++

* Torrent file parsing
* Peer wire protocol
* Piece selection & download management
* Raw sockets, no training wheels

➡️ *Deep dive into real world network protocols*

---

### **Redis Server Clone**

🔗 [https://github.com/Infinage/cpp-experiments/tree/main/redis-server](https://github.com/Infinage/cpp-experiments/tree/main/redis-server)

> Lightweight Redis server clone in C++

* Single-threaded, event-driven design
* Raw sockets
* RESP protocol parsing
* Command handling & in-memory storage

➡️ *Exploring server design & protocol correctness*

---

## 🧪 Selected Supporting Projects

### **JSON Parser**

🔗 [https://github.com/Infinage/cpp-experiments/tree/main/json-parser](https://github.com/Infinage/cpp-experiments/tree/main/json-parser)

Header-only JSON library (`json.hpp`)

* Parsing, validation, construction
* Zero dependencies
* Focus on clean API & correctness

---

### **Maze Generator & Solver**

🔗 [https://github.com/Infinage/maze](https://github.com/Infinage/maze)

* 5 generation algorithms (Wilson, Kruskal, Prim, Ellers, DFS)
* 3 solvers (Dijkstra, A*, Dead-end filling)
* CLI-based, algorithm-focused

---

### **Interpreters & Tools**

🔗 [https://github.com/Infinage/cpp-experiments](https://github.com/Infinage/cpp-experiments)

* Brainfuck interpreter
* ASCII art generator
* Code judge
* Mandelbrot explorer
* Re-implementations of `tar`, `uniq`, `xxd`, `wc`, shell utilities

➡️ *Relearning fundamentals by rebuilding them*

---

## Dotfiles

This repository also contains my personal dotfiles, managed with GNU Stow. To deploy them to your home directory, navigate to the repository's root and run:

```
stow -t ~ dotfiles
```

Note: We are intentionally not using the `--no-folding` option, as we want `.password-store` to be tracked as a folder rather than a symlink.

---

## 📬 Get in Touch

* LinkedIn: [Naresh Jagadeeesan](https://www.linkedin.com/in/naresh-jagadeesan/)
* Email: [naresh.naresh000@gmail.com](mailto:naresh.naresh000@gmail.com)

