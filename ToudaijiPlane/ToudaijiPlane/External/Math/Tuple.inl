//------------------------------------------------------------------------------
template<unsigned int DIM, typename TYPE>
Tuple<DIM, TYPE>::Tuple()
{
    for (unsigned int i = 0; i < DIM; i++)
    {
        data_[i] = 0;
    }
}
//------------------------------------------------------------------------------
template<unsigned int DIM, typename TYPE>
Tuple<DIM, TYPE>::Tuple(const Tuple& orig)
{
    *this = orig; 
}
//------------------------------------------------------------------------------
template<unsigned int DIM, typename TYPE>
Tuple<DIM, TYPE>& Tuple<DIM, TYPE>::operator=(const Tuple& orig)
{
    for (unsigned int i = 0; i < DIM; i++)
    {
        data_[i] = orig.data_[i];
    }
    return *this;    
}
//------------------------------------------------------------------------------
template<unsigned int DIM, typename TYPE>
Tuple<DIM, TYPE>& Tuple<DIM, TYPE>::operator=(const TYPE& a)
{
    for (unsigned int i = 0; i < DIM; i++)
    {
        data_[i] = a;
    }
    return *this;    
}
//------------------------------------------------------------------------------
template<unsigned int DIM, typename TYPE>
TYPE& Tuple<DIM, TYPE>::operator[](unsigned int i)
{
    return data_[i];
}
//------------------------------------------------------------------------------
template<unsigned int DIM, typename TYPE>
const TYPE& Tuple<DIM, TYPE>::operator[](unsigned int i) const
{
    return data_[i];
}
//------------------------------------------------------------------------------