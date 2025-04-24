#import "@preview/touying:0.5.5": *
#import themes.simple: *

// set text color to gray
#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: "russcip - 24.04.2025",
)

#title-slide[
  #figure(image("russcip-logo.png", width: 100%))
  
  #v(-4em)
  #text(size: 20pt)[A Rust interface for SCIP]

  #text(size: 10pt)[by Mohammed Ghannam (#link("https://github.com/mmghannam")[#text(blue)[\@mmghannam]])]
]

// #components.adaptive-columns(outline(indent: 1em))

/* ---------------------------------------------------- */

== How it started?

- Late 2022: Learning Rust in my free time.
- Rust is great, it would be amazing to use SCIP from Rust.
- `good_lp` issue to add support for SCIP.

== Why write a Rust interface for SCIP?
- No-overhead when binding to C.
- Memory safe and thread safe at compile time.
- No garbage collector.
- Great community and ecosystem.
- Great support for parallelism and concurrency.

== First Step: bindings

`scip_sys`: (unsafe) Rust bindings to SCIP's C API

- covers all of SCIP's C API
- can be hard to work with.

// Show an example here from the scip_sys crate

== Second Step -  a Safe Wrapper
`russcip`: a safe and idiomatic Rust wrapper around `scip_sys`

=== Philosophy
- Use Rust's type system to enforce safety and correctness.
- Hide complexity and boilerplate code.

== Current Features
- Easy access to SCIP through the `bundled` feature.
- Automatic memory management.
- Separate stages for model wrappers, avoiding many user errors at compile time. e.g. `focus_node()`
- Aim to reduce boilerplate code and improve usability.
- Simpler API for writing models (also through `good_lp`) and implementing callbacks.
- Unsafe access to SCIP's C API when needed through the `ffi` module.

= russcip Guide

/*

- Modeling 
- Setting parameters, and emphasis modes. 
- Plugins: the ones covered in russcip with some use cases:
+++ Event handler to collect data
+++ Primal heuristic to support current model with improving heuristics. 
+++ Separators (some branch-and-cut application or a simple separation routine) 
+++ Branching rules (maybe simple random branching here as example)
+++ Pricers: for column generation (we could use your new example here, thank you by the way ^^)
- Maybe also introduce what else is possible with SCIP in general so if needed we could collaborate on some wrappers for the needed functionality :)
*/

#let comment(t) = {
  text(fill: gray, size: 20pt, t)
}

== Modeling
#slide[
#v(1em)
#grid(
  columns: (30%, 75%),
  align(center + horizon)[
    #text(size: 20pt)[
    #block[
      maximize #h(1em) 3x₁ + 2x₂
      #align(left)[
      subject to:
      ]
      #align(right)[
      2x₁ + x₂ ≤ 100 #h(1em) (c₁)

      x₁ + 2x₂ ≤ 80 #h(1em) (c₂)
      
      x₁, x₂ ≥ 0 and integer
      ]
    ]
    ]
  ],
  [
    #align(center + horizon)[
  #text(size: 16pt)[
    ```rust
    // Create model
    let mut model = Model::default().maximize();

    // Add variables
    let x1 = model.add(var().int(0..).obj(3.).name("x1"));
    let x2 = model.add(var().int(0..).obj(2.).name("x2"));

    // Add constraints
    model.add(cons().name("c1").coef(&x1, 2.).coef(&x2, 1.).le(100.));
    model.add(cons().name("c2").coef(&x1, 1.).coef(&x2, 2.).le(80.));
    ```
  ]
    ]
  ]
)
]


== Querying the solution
#slide[
#text(size: 14pt)[
```rust
let solved_model = model.solve();

let status = solved_model.status();
println!("Solved with status {:?}", status);

let obj_val = solved_model.obj_val();
println!("Objective value: {}", obj_val);

let sol = solved_model.best_sol().unwrap();
let vars = solved_model.vars();

for var in vars {
    println!("{} = {}", var.name(), sol.val(&var));
}
```]
][
#box(fill: gray.lighten(80%), radius: 5pt, inset: 7pt)[
  #text(size: 7pt)[
    ```
    feasible solution found by trivial heuristic after 0.0 seconds, objective value 0.000000e+00
presolving:
(round 1, fast)       0 del vars, 0 del conss, 0 add conss, 3 chg bounds, 0 chg sides, 0 chg coeffs, 0 upgd conss, 0 impls, 0 clqs
(round 2, exhaustive) 0 del vars, 0 del conss, 0 add conss, 3 chg bounds, 0 chg sides, 0 chg coeffs, 2 upgd conss, 0 impls, 0 clqs
   (0.0s) symmetry computation started: requiring (bin +, int +, cont +), (fixed: bin -, int -, cont -)
   (0.0s) no symmetry present (symcode time: 0.00)
presolving (3 rounds: 3 fast, 2 medium, 2 exhaustive):
 0 deleted vars, 0 deleted constraints, 0 added constraints, 3 tightened bounds, 0 added holes, 0 changed sides, 0 changed coefficients
 0 implications, 0 cliques
presolved problem has 2 variables (0 bin, 2 int, 0 impl, 0 cont) and 2 constraints
      2 constraints of type <varbound>
transformed objective value is always integral (scale: 1)
Presolving Time: 0.01
transformed 1/1 original solutions to the transformed problem space

 time | node  | left  |LP iter|LP it/n|mem/heur|mdpt |vars |cons |rows |cuts |sepa|confs|strbr|  dualbound   | primalbound  |  gap   | compl. 
p 0.0s|     1 |     0 |     0 |     - | vbounds|   0 |   2 |   2 |   2 |   0 |  0 |   0 |   0 | 2.300000e+02 | 1.500000e+02 |  53.33%| unknown
* 0.0s|     1 |     0 |     2 |     - |    LP  |   0 |   2 |   2 |   2 |   0 |  0 |   4 |   0 | 1.600000e+02 | 1.600000e+02 |   0.00%| unknown
  0.0s|     1 |     0 |     2 |     - |   596k |   0 |   2 |   2 |   2 |   0 |  0 |   4 |   0 | 1.600000e+02 | 1.600000e+02 |   0.00%| unknown

SCIP Status        : problem is solved [optimal solution found]
Solving Time (sec) : 0.02
Solving Nodes      : 1
Primal Bound       : +1.60000000000000e+02 (3 solutions)
Dual Bound         : +1.60000000000000e+02
Gap                : 0.00 %
Solved with status Optimal
Objective value: 160
t_x1 = 40
t_x2 = 20
```
]
]
]



== Setting Parameters

SCIP has thousands of parameters. A full list can be found #link("https://www.scipopt.org/doc/html/PARAMETERS.php")[#text(blue)[here]]

#text(size: 20pt)[
```rust
model.set_param("limits/softtime", 100.0);
```
]

== Emphasis Modes
SCIP has meta-parameters that can be set to influence the solving process.

#text(size: 20pt)[
```rust
let mut model = Model::default();
model.set_heuristics(ParamSetting::Aggressive);
model.set_presolving(ParamSetting::Off);
model.set_separating(ParamSetting::Aggressive);
```
]


= Plugins

== Event Handlers
SCIP broadcasts many events during the solving process, callbacks can be registered to listen to these events.

=== Example
event handler to print node data, #link("https://github.com/scipopt/russcip/blob/main/examples/node_event_handler.rs")[#text(blue)[here]].

== Primal Heuristics
Primal heuristics are used to find feasible solutions during the solving process.

=== Example
Primal heuristic that rounds the current LP solution, #link("https://github.com/scipopt/russcip/blob/main/examples/random_rounding.rs")[#text(blue)[here]].

== Branching Rules
Branching rules are used to select the next variable to branch on during the solving process (also enables custom branching).

=== Example
Most infeasible branching rule, #link("https://github.com/scipopt/russcip/blob/main/examples/most_infeasible_branching.rs")[#text(blue)[here]].

== Separators
Separators can add valid inequalities to the model to tighten the LP relaxation.

=== Example
Clique separator for set partitioning problem, #link("https://github.com/scipopt/russcip/blob/main/examples/clique_separator.rs")[#text(blue)[here]].


== Constraint Handlers

The main plugin type in SCIP, constraint handlers are used to add new constraints to the model and manage them.

=== Example

Subtour elimination constraint handler for the traveling salesman problem, #link("https://github.com/scipopt/russcip/blob/main/examples/tsp.rs")[#text(blue)[here]]

== Column Generation: Pricers

Column generation is a technique used to solve large-scale linear programming problems by solving a restricted master problem and generating new variables (columns) to add to the model.
=== Example
Pricer for the Cutting Stock Problem, #link("https://github.com/scipopt/russcip/blob/main/examples/cutting_stock.rs")[#text(blue)[here]].

== Current State

#image("current_state.png", width: 80%)

= Future Work

== Future Work: Simple Event Handlers
- Less boilerplate code for simple event handlers, by passing a closure and an event type.
#text(size: 22pt)[
```rust
let mut model = Model::default();
// ... some variables and constraints
model.set_callback(EventMask::NODE_FOCUSED, |model, event| {
    let node_number = model.focus_node().number();
    let node_depth = model.focus_node().depth();
    println!("Solved node number: {}, at depth: {}", node_number, node_depth);
});
```
]

== Future Work: More Safe Wrappers
SCIP supports many other callbacks, such as:
  - Reader
  - Presolver
  - Cut selector

Many more API functions are available in SCIP, a full list can be found #link("https://github.com/scipopt/scip-sys")[#text(blue)[here]].  

== Future Work: Modeling

Enable more powerful modeling features for the many constraint types available in SCIP through a generic procedural macro. 

#text(size: 20pt)[
```rust
model.add(c!( 2 * x + y <= 10)); // linear constraint
model.add(c!( x * y <= 10)); // nonlinear constraint
model.add(c!( e ^ y <= 10)); // exponential constraint
model.add(c!( log(y) <= 10)); // logarithmic constraint
model.add(c!( sqrt(x) <= 10)); // square root constraint

model.add(c!( y -> x <= 10)); // indicator constraint
model.add(c!( (x + y == 10) && (x >= 5)  )); // AND constraint
model.add(c!( (x + y == 10) || (x >= 5)  )); // OR constraint
```
]
--- 
== Future Work: Parallel plugins

Enable support for adding parallel plugins. They run on a separate thread and can only communicate with SCIP through an event handler and a message queue to modify the model.


--- 

= 
Thank you for your attention!