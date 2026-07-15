// Tests DebugValue emission for float2x2 matrix local variables.
// Slang emits one DebugValue per scalar element of kIROp_MakeMatrix, so the
// matrix is tracked as a flat 4-element composite (m00, m01, m10, m11) indexed
// by the operand order of makeMatrix.
//TEST:SPVDB_DEBUGGER(filecheck=SPVDB): -entry main -stage compute

[shader("compute")]
[numthreads(1, 1, 1)]
void main(uniform RWStructuredBuffer<float> inputA,
          uniform RWStructuredBuffer<float> inputB,
          uniform RWStructuredBuffer<uint>  output)
{
    float2x2 m = float2x2(inputA[0], 0.0, 0.0, inputB[0]);   // line 13
    output[0] = uint(m[0][0] + m[1][1]);                      // line 14
}

// SPVDB-CMD: descriptor 0 0 [3.5]
// SPVDB-CMD: descriptor 0 1 [5.5]
// SPVDB-CMD: descriptor 0 2 [0]
// SPVDB-CMD: break matrix-locals.slang 14
// SPVDB-CMD: run
// SPVDB-CMD: locals
// SPVDB-CMD: run
// SPVDB-CMD: read 0 2

// Slang emits 4 scalar DebugValues for makeMatrix(a, 0, 0, b):
// elements[0]=3.5, [1]=0, [2]=0, [3]=5.5 → printed as (3.5, 0, 0, 5.5).
// SPVDB: stopped: Breakpoint
// SPVDB: local: m = (3.5, 0, 0, 5.5)
// SPVDB: stopped: EntryFinished
// SPVDB: read[0][2]: [9]
