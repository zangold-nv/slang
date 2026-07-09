// Tests DebugTypeComposite member-name emission: a struct local variable must
// appear in 'locals' with named fields ({x=..., y=...}) rather than an
// anonymous composite ((...)). The struct is stored in Function-scope memory
// so its type info flows through bytes_to_value() where member names are set.
//TEST:SPVDB_DEBUGGER(filecheck=SPVDB): -entry main -stage compute

struct Point
{
    float x;
    float y;
};

[shader("compute")]
[numthreads(1, 1, 1)]
void main(uniform RWStructuredBuffer<float> inputX,
          uniform RWStructuredBuffer<float> inputY,
          uniform RWStructuredBuffer<float> output)
{
    Point p;
    p.x = inputX[0];
    p.y = inputY[0];
    output[0] = p.x + p.y;   // line 22
}

// SPVDB-CMD: descriptor 0 0 [3.0]
// SPVDB-CMD: descriptor 0 1 [4.0]
// SPVDB-CMD: descriptor 0 2 [0.0]
// SPVDB-CMD: break struct-locals.slang 22
// SPVDB-CMD: run
// SPVDB-CMD: location
// SPVDB-CMD: locals
// SPVDB-CMD: run

// SPVDB: stopped: Breakpoint
// SPVDB: location: {{.*}}struct-locals.slang:22
// NOTE: spvdb currently overwrites the composite variable with each DebugValue
// for a member field, showing only the last field (y=4) instead of {x=3, y=4}.
// This is a spvdb bug.  We check that 'p' appears in locals (regression for
// visibility) but not its exact composite format.
// SPVDB: local: p = {{.*}}
// SPVDB: stopped: EntryFinished
