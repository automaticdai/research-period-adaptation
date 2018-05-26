/* Copyright 2003-2009 The MathWorks, Inc. */

#ifndef _SFUN_CPPCOUNT_CPP_
#define _SFUN_CPPCOUNT_CPP_

// Define a generic template that can accumulate
// values of any numeric data type
template <class DataType> class GenericAdder {
private:
    DataType Peak;
public:
    GenericAdder() {
        Peak = 0;
    }
    DataType AddTo(DataType Val) {
        Peak += Val;
        return Peak;
    }
    DataType GetPeak() const {
    	return Peak;
    }
    void SetPeak(DataType v) {
    	Peak = v;
    }
};

// Specialize the generic adder to a 'double'
// data type adder
class DoubleAdder : public GenericAdder<double> {};

#endif


