/*!
** Tuple.h
**    
** @since 2013-09-06    
*/
#ifndef TUPLE_H__
#define TUPLE_H__

#include <string>
#include <sstream>
#include <iostream>

namespace Math
{
    /*!
    ** Implementation of a tuple.
    **    
    ** @since 2013-09-06
    */
    template<unsigned int DIM, typename TYPE>
    class Tuple
    {
    public:
        Tuple();
        ~Tuple() {};

        Tuple(const Tuple& orig);
        Tuple& operator=(const Tuple& orig);

        inline Tuple<DIM, TYPE>& operator=(const TYPE& a);
        inline operator const TYPE*() const {return data_;}
        inline operator TYPE*() {return data_;}

        inline const TYPE& operator[](unsigned int i) const;
        inline TYPE& operator[](unsigned int i);

    private:
        TYPE data_[DIM];
    };

    #include "Tuple.inl"

    typedef Tuple<2, unsigned int> Tuple2UI;
    typedef Tuple<3, unsigned int> Tuple3UI;
}
#endif /* end of include guard: TUPLE_H__ */