//------------------------------------------------------------------------------
template<typename T>
Vector4<T>::Vector4(const T& x, const T& y, const T& z)
{
    data_[0] = x;
    data_[1] = y;
    data_[2] = z;
}
//------------------------------------------------------------------------------
template<typename T>
Vector4<T>::Vector4(const Vector4& orig)
{
    data_ = orig.data_;
}
//------------------------------------------------------------------------------
template<typename T>
Vector4<T>& Vector4<T>::operator=(const Vector4<T>& orig)
{
    data_ = orig.data_;
    return *this;
}
//------------------------------------------------------------------------------
template<typename T>
Vector4<T>& Vector4<T>::operator=(const T& a)
{
    data_ = a;
    return *this;
}
//------------------------------------------------------------------------------
template<typename T>
T& Vector4<T>::operator[](unsigned int i)
{
    CGTK_ASSERT(i < 4)

    return data_[i];
}
//------------------------------------------------------------------------------
template<typename T>
const T& Vector4<T>::operator[](unsigned int i) const
{
    CGTK_ASSERT(i < 4)
    
    return data_[i];
}
//------------------------------------------------------------------------------
template<typename T>
std::string Vector4<T>::ToString() const
{
    std::stringstream s;
    s << "[x = " << data_[0] << " y = " << data_[1] << " z = " << data_[2] << "w = " << data_[3] << "]";
    return s.str();
}
//------------------------------------------------------------------------------