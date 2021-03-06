# <a href="http://yixuan.cos.name/spectra"><img src="http://yixuan.cos.name/spectra/img/logo.png" width="200px" /></a>

[![Build Status](https://travis-ci.org/yixuan/spectra.svg?branch=master)](https://travis-ci.org/yixuan/spectra)

[**Spectra**](http://yixuan.cos.name/spectra) stands for **Sp**arse **E**igenvalue **C**omputation **T**oolkit
as a **R**edesigned **A**RPACK. It is a C++ library for large scale eigenvalue
problems, built on top of [Eigen](http://eigen.tuxfamily.org),
an open source linear algebra library.

**Spectra** is implemented as a header-only C++ library, whose only dependency,
**Eigen**, is also header-only. Hence **Spectra** can be easily embedded in
C++ projects that require calculating eigenvalues of large matrices.

## Relation to ARPACK

[ARPACK](http://www.caam.rice.edu/software/ARPACK/) is a software written in
FORTRAN for solving large scale eigenvalue problems. The development of
**Spectra** is much inspired by ARPACK, and as the whole name indicates,
**Spectra** is a redesign of the ARPACK library using C++ language.

In fact, **Spectra** is based on the algorithms described in the
[ARPACK Users' Guide](http://www.caam.rice.edu/software/ARPACK/UG/ug.html),
but it does not use the ARPACK code, and it is **NOT** a clone of ARPACK for C++.
In short, **Spectra** implements the major algorithms in ARPACK,
but **Spectra** provides a completely different interface, and it does not
depend on ARPACK.

## Common Usage

**Spectra** is designed to calculate a specified number (`k`) of eigenvalues
of a large square matrix (`A`). Usually `k` is much less than the size of matrix
(`n`), so that only a few eigenvalues and eigenvectors are computed, which
in general is more efficient than calculating the whole spectral decomposition.
Users can choose eigenvalue selection rules to pick up the eigenvalues of interest,
such as the largest `k` eigenvalues, or eigenvalues with largest real parts,
etc.

To use the eigen solvers in this library, the user does not need to directly
provide the whole matrix, but instead, the algorithm only requires certain operations
defined on `A`, and in the basic setting, it is simply the matrix-vector
multiplication. Therefore, if the matrix-vector product `A * x` can be computed
efficiently, which is the case when `A` is sparse, **Spectra**
will be very powerful for large scale eigenvalue problems.

There are two major steps to use the **Spectra** library:

1. Define a class that implements a certain matrix operation, for example the
matrix-vector multiplication `y = A * x` or the shift-solve operation
`y = inv(A - ?? * I) * x`. **Spectra** has defined a number of
helper classes to quickly create such operations from a matrix object.
See the documentation of
[DenseGenMatProd](http://yixuan.cos.name/spectra/doc/classSpectra_1_1DenseGenMatProd.html),
[DenseSymShiftSolve](http://yixuan.cos.name/spectra/doc/classSpectra_1_1DenseSymShiftSolve.html), etc.
2. Create an object of one of the eigen solver classes, for example
[SymEigsSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1SymEigsSolver.html)
for symmetric matrices, and
[GenEigsSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1GenEigsSolver.html)
for general matrices. Member functions
of this object can then be called to conduct the computation and retrieve the
eigenvalues and/or eigenvectors.

Below is a list of the available eigen solvers in **Spectra**:
- [SymEigsSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1SymEigsSolver.html):
for real symmetric matrices
- [GenEigsSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1GenEigsSolver.html):
for general real matrices
- [SymEigsShiftSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1SymEigsShiftSolver.html):
for real symmetric matrices using the shift-and-invert mode
- [GenEigsRealShiftSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1GenEigsRealShiftSolver.html):
for general real matrices using the shift-and-invert mode,
with a real-valued shift
- [GenEigsComplexShiftSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1GenEigsRealShiftSolver.html):
for general real matrices using the shift-and-invert mode,
with a complex-valued shift

## Examples

Below is an example that demonstrates the use of the eigen solver for symmetric
matrices.

```cpp
#include <Eigen/Core>
#include <SymEigsSolver.h>  // Also includes <MatOp/DenseSymMatProd.h>
#include <iostream>

using namespace Spectra;

int main()
{
    // We are going to calculate the eigenvalues of M
    Eigen::MatrixXd A = Eigen::MatrixXd::Random(10, 10);
    Eigen::MatrixXd M = A + A.transpose();

    // Construct matrix operation object using the wrapper class DenseGenMatProd
    DenseSymMatProd<double> op(M);

    // Construct eigen solver object, requesting the largest three eigenvalues
    SymEigsSolver< double, LARGEST_ALGE, DenseSymMatProd<double> > eigs(&op, 3, 6);

    // Initialize and compute
    eigs.init();
    int nconv = eigs.compute();

    // Retrieve results
    Eigen::VectorXd evalues;
    if(eigs.info() == SUCCESSFUL)
        evalues = eigs.eigenvalues();

    std::cout << "Eigenvalues found:\n" << evalues << std::endl;

    return 0;
}
```

Sparse matrix is supported via the `SparseGenMatProd` class.

```cpp
#include <Eigen/Core>
#include <Eigen/SparseCore>
#include <GenEigsSolver.h>
#include <MatOp/SparseGenMatProd.h>
#include <iostream>

using namespace Spectra;

int main()
{
    // A band matrix with 1 on the main diagonal, 2 on the below-main subdiagonal,
    // and 3 on the above-main subdiagonal
    const int n = 10;
    Eigen::SparseMatrix<double> M(n, n);
    M.reserve(Eigen::VectorXi::Constant(n, 3));
    for(int i = 0; i < n; i++)
    {
        M.insert(i, i) = 1.0;
        if(i > 0)
            M.insert(i - 1, i) = 3.0;
        if(i < n - 1)
            M.insert(i + 1, i) = 2.0;
    }

    // Construct matrix operation object using the wrapper class SparseGenMatProd
    SparseGenMatProd<double> op(M);

    // Construct eigen solver object, requesting the largest three eigenvalues
    GenEigsSolver< double, LARGEST_MAGN, SparseGenMatProd<double> > eigs(&op, 3, 6);

    // Initialize and compute
    eigs.init();
    int nconv = eigs.compute();

    // Retrieve results
    Eigen::VectorXcd evalues;
    if(eigs.info() == SUCCESSFUL)
        evalues = eigs.eigenvalues();

    std::cout << "Eigenvalues found:\n" << evalues << std::endl;

    return 0;
}
```

And here is an example for user-supplied matrix operation class.

```cpp
#include <Eigen/Core>
#include <SymEigsSolver.h>
#include <iostream>

using namespace Spectra;

// M = diag(1, 2, ..., 10)
class MyDiagonalTen
{
public:
    int rows() { return 10; }
    int cols() { return 10; }
    // y_out = M * x_in
    void perform_op(double *x_in, double *y_out)
    {
        for(int i = 0; i < rows(); i++)
        {
            y_out[i] = x_in[i] * (i + 1);
        }
    }
};

int main()
{
    MyDiagonalTen op;
    SymEigsSolver<double, LARGEST_ALGE, MyDiagonalTen> eigs(&op, 3, 6);
    eigs.init();
    eigs.compute();
    if(eigs.info() == SUCCESSFUL)
    {
        Eigen::VectorXd evalues = eigs.eigenvalues();
        std::cout << "Eigenvalues found:\n" << evalues << std::endl;
    }

    return 0;
}
```

## Shift-and-invert Mode

When we want to find eigenvalues that are closest to a number `??`,
for example to find the smallest eigenvalues of a positive definite matrix
(in which case `?? = 0`), it is advised to use the shift-and-invert mode
of eigen solvers.

In the shift-and-invert mode, selection rules are applied to `1/(?? - ??)`
rather than `??`, where `??` are eigenvalues of `A`.
To use this mode, users need to define the shift-solve matrix operation. See
the documentation of
[SymEigsShiftSolver](http://yixuan.cos.name/spectra/doc/classSpectra_1_1SymEigsShiftSolver.html)
for details.

## Documentation

The [API reference](http://yixuan.cos.name/spectra/doc/) page contains the documentation
of **Spectra** generated by [Doxygen](http://www.doxygen.org/),
including all the background knowledge, example code and class APIs.

More information can be found in the project page [http://yixuan.cos.name/spectra](http://yixuan.cos.name/spectra).

## License

**Spectra** is an open source project licensed under
[MPL2](https://www.mozilla.org/MPL/2.0/), the same license used by **Eigen**.
