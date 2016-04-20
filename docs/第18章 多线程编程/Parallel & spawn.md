##Parallel & Spawn

Nim has two flavors of parallelism:

Nim有两种风格的并行：

1.Structured parallelism via the parallel statement.

1.  通过parallel语句的结构化并行

2.Unstructured parallelism via the standalone spawn statement.

2.  通过单独的spawn语句的非结构化并行

Nim has a builtin thread pool that can be used for CPU intensive tasks. For IO intensive tasks the async and await features should be used instead. Both parallel and spawn need the threadpool module to work.

Nim有一个内建的线程池，它能够用于CPU的密集型任务。对于IO密集型任务应该使用async和await 。Parallel和spawn都需要threadpool 模块来工作。

Somewhat confusingly, spawn is also used in the parallel statement with slightly different semantics. spawn always takes a call expression of the form f(a, ...). Let T be f's return type. If T is void then spawn's return type is also void otherwise it is FlowVar[T].

有些令人困惑的是，spawn也以稍微不同的语义用在parallel中。 Spawn总是以f(a,.....)的形式调用，假设T为f的返回类型，如果T是void，那么spawn的返回类型也是void，否则它是FlowVar[T].

Within a parallel section sometimes the FlowVar[T] is eliminated to T. This happens when T does not contain any GC'ed memory. The compiler can ensure the location in location = spawn f(...) is not read prematurely within a parallel section and so there is no need for the overhead of an indirection via FlowVar[T] to ensure correctness.

在一个parallel部分内有时候FlowVar[T]是清除T的？？？。这个发生在当T没有包含任何的GC的内存。在一个parallel部分中，编译器能够确保location = spawn f(....) 的位置不被过早的读，因此不需要额外的开销通过FlowVar[T]来确定正确性。

Note: Currently exceptions are not propagated between spawn'ed tasks!

注意：当前的的异常在spawn的任务中是不传播的。

###Spawn statement

spawn can be used to pass a task to the thread pool:

spawn能够用于传递一个任务到线程池：

```
import threadpool

proc processLine(line: string) =
  discard "do some heavy lifting here"

for x in lines("myinput.txt"):
  spawn processLine(x)

sync()
```

For reasons of type safety and implementation simplicity the expression that spawn takes is restricted:

由于类型安全和方便实现的原因，spawn表达式是受限制的：

It must be a call expression f(a, ...).

它必须是一个调用表达式f(a, ...).

f must be gcsafe.

f必须是gcsafe.

f must not have the calling convention closure.

f不能有闭包调用约定。

f's parameters may not be of type var. This means one has to use raw ptr's for data passing reminding the programmer to be careful.

f的参数不能是var类型。这意味着必须使用原生的ptr来传递数据，提醒程序员这里要小心。

ref parameters are deeply copied which is a subtle semantic change and can cause performance problems but ensures memory safety. This deep copy is performed via system.deepCopy and so can be overriden.

ref参数是深拷贝，这是一个微妙的语义变化，它可能造成性能问题，但是确保了内存安全。这个深拷贝通过 system.deepCopy 执行，因此它能够被重写。

For safe data exchange between f and the caller a global TChannel needs to be used. However, since spawn can return a result, often no further communication is required.

为了在f和调用者之间进行安全的数据交换，需要用到一个全局的TChannel。然而，由于spawn能够返回一个结果，通常不需要进一步沟通。

spawn executes the passed expression on the thread pool and returns a data flow variable FlowVar[T] that can be read from. The reading with the ^ operator is blocking. However, one can use awaitAny to wait on multiple flow variables at the same time:

Spawn在线程池中执行传递的表达式，并且返回一个可以读取的数据流变量FlowVar[T]。使用 ^ 操作符读取是阻塞模式。然而，可以使用awaitAny在同一时间等待多个流变量。

```
import threadpool, ...

# wait until 2 out of 3 servers received the update:
proc main =
  var responses = newSeq[FlowVarBase](3)
  for i in 0..2:
    responses[i] = spawn tellServer(Update, "key", "value")
  var index = awaitAny(responses)
  assert index >= 0
  responses.del(index)
  discard awaitAny(responses)
```

Data flow variables ensure that no data races are possible. Due to technical limitations not every type T is possible in a data flow variable: T has to be of the type ref, string, seq or of a type that doesn't contain a type that is garbage collected. This restriction is not hard to work-around in practice.

数据流变量确保没有数据竞争是可能的。由于技术上的限制并不是每一个类型T都能够在数据流变量里：T必须是类型ref、string、seq或者没有包含任何垃圾回收类型的类型。这个限制在实践中是不难绕过的。

###Parallel statement

Example:

```
# Compute PI in an inefficient way
import strutils, math, threadpool

proc term(k: float): float = 4 * math.pow(-1, k) / (2*k + 1)

{.experimental.}
proc pi(n: int): float =
  var ch = newSeq[float](n+1)
  parallel:
    for k in 0..ch.high:
      ch[k] = spawn term(float(k))
  for k in 0..ch.high:
result += ch[k]

echo formatFloat(pi(5000))
```

The parallel statement is the preferred mechanism to introduce parallelism in a Nim program. A subset of the Nim language is valid within a parallel section. This subset is checked to be free of data races at compile time. A sophisticated disjoint checker ensures that no data races are possible even though shared memory is extensively supported!

对于在Nim程序中引入并行，parallel是更好的机制。一个Nim语言的子集在一个parallel部分是有效的。这个子集在编译时期将会被自由的检查数据竞争。一个复杂的不相交的检查能够确保没有数据竞争是可能的，即使是广泛的之前共享内存。

The subset is in fact the full language with the following restrictions / changes:

子集实际上是整个语言带有下面的限制/改变：

spawn within a parallel section has special semantics.

在一个parallel部分中的spawn有特殊的语义

Every location of the form a[i] and a[i..j] and dest where dest is part of the pattern dest = spawn f(...) has to be provably disjoint. This is called the disjoint check.

形如a[i] 和 a[i..j] 和 dest , dest是模式 dest = spawn f(...)的一部分，必须被证明是分离的。这就是所谓的解体检查。

Every other complex location loc that is used in a spawned proc (spawn f(loc)) has to be immutable for the duration of the parallel section. This is called the immutability check. Currently it is not specified what exactly "complex location" means. We need to make this an optimization!

每一个其他的复合位置 loc 在parallel部分期间必须是不变的，它被用于一个并行的过程（spawn f(log)）, 

Every array access has to be provably within bounds. This is called the bounds check.

每一个数组访问必须被证明是在允许范围内。这就是所谓的边界检查。

Slices are optimized so that no copy is performed. This optimization is not yet performed for ordinary slices outside of a parallel section.

切片进行了优化，以便不执行复制。这种优化对于parallel部分外的普通切片还没有执行。
