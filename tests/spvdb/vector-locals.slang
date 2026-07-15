// Tests DebugValue emission for float3 vector local variables.
// The composite value is printed as (x, y, z) by spvdb_value_str.
//TEST:SPVDB_DEBUGGER(filecheck=SPVDB): -entry main -stage compute

[shader("compute")]
[numthreads(1, 1, 1)]
void main(uniform RWStructuredBuffer<float> inputX,
          uniform RWStructuredBuffer<float> inputY,
          uniform RWStructuredBuffer<float> inputZ,
          uniform RWStructuredBuffer<uint>  output)
{
    float3 v = float3(inputX[0], inputY[0], inputZ[0]);   // line 12
    output[0] = uint(v.x + v.y + v.z);                    // line 13
}

// SPVDB-CMD: descriptor 0 0 [1.5]
// SPVDB-CMD: descriptor 0 1 [2.5]
// SPVDB-CMD: descriptor 0 2 [3.5]
// SPVDB-CMD: descriptor 0 3 [0]
// SPVDB-CMD: break vector-locals.slang 13
// SPVDB-CMD: run
// SPVDB-CMD: locals
// SPVDB-CMD: run
// SPVDB-CMD: read 0 3

// Slang now emits one DebugValue per vector element so spvdb can reconstruct
// the full vector value.  v.x=1.5, v.y=2.5, v.z=3.5 → (1.5, 2.5, 3.5).
// SPVDB: stopped: Breakpoint
// SPVDB: local: v = (1.5, 2.5, 3.5)
// SPVDB: stopped: EntryFinished
// SPVDB: read[0][3]: [7]
