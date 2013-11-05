//------------------------------------------------------------------------------
template<typename T>
Vector2<T>::Vector2(const T& x, const T& y)
{
    data_[0] = x;
    data_[1] = y;
}
//------------------------------------------------------------------------------
template<typename T>
Vector2<T>::Vector2(const Vector2& orig)
{
    data_ = orig.data_;
}
//------------------------------------------------------------------------------
template<typename T>
Vector2<T>& Vector2<T>::operator=(const Vector2& orig)
{
    data_ = orig.data_;
    return *this;
}
//------------------------------------------------------------------------------
template<typename T>
std::string Vector2<T>::ToString() const
{
    std::stringstream s;
    s << "[x = " << data_[0] << " y = " << data_[1] << "]";
    return s.str();
}
//------------------------------------------------------------------------------