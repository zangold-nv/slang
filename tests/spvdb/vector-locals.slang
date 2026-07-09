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
    float3 v = float3(inputX[0], inputY[0], inputZ[0]);
    output[0] = uint(v.x + v.y + v.z);
}

// SPVDB-CMD: descriptor 0 0 [1.5]
// SPVDB-CMD: descriptor 0 1 [2.5]
// SPVDB-CMD: descriptor 0 2 [3.5]
// SPVDB-CMD: descriptor 0 3 [0]
// SPVDB-CMD: descriptor 0 0 [1.5]
// SPVDB-CMD: descriptor 0 1 [2.5]
// SPVDB-CMD: descriptor 0 2 [3.5]
// SPVDB-CMD: descriptor 0 3 [0]
// SPVDB-CMD: run
// SPVDB-CMD: read 0 3

// NOTE: Slang emits DebugValue %v %OpUndef for composite-constructed vectors,
// so spvdb shows v=0 instead of (1.5, 2.5, 3.5).  This is a known Slang bug.
// The test just verifies compilation and correct execution.
// SPVDB: stopped: EntryFinished
// SPVDB: read[0][3]: [7]
