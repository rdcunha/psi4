include(CheckIncludeFile)

# C++ stuff
macro(architecture_flags_CXX _enable_vector_unit_list _available_vector_units_list _march_flag_list _disable_vector_unit_list)
if(CMAKE_CXX_COMPILER MATCHES "/(icpc|icc)$") # ICC (on Linux)
   _my_find(_available_vector_units_list "avx2"    _found)
   if(_found)
      AddCompilerFlag("-xCORE-AVX2" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
   else(_found)
      _my_find(_available_vector_units_list "f16c"    _found)
      if(_found)
         AddCompilerFlag("-xCORE-AVX-I" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
      else(_found)
         _my_find(_available_vector_units_list "avx"    _found)
         if(_found)
            AddCompilerFlag("-xAVX" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
         else(_found)
            _my_find(_available_vector_units_list "sse4.2" _found)
            if(_found)
               AddCompilerFlag("-xSSE4.2" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
            else(_found)
               _my_find(_available_vector_units_list "sse4.1" _found)
               if(_found)
                  AddCompilerFlag("-xSSE4.1" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
               else(_found)
                  _my_find(_available_vector_units_list "ssse3"  _found)
                  if(_found)
                     AddCompilerFlag("-xSSSE3" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
                  else(_found)
                     _my_find(_available_vector_units_list "sse3"   _found)
                     if(_found)
                        # If the target host is an AMD machine then we still want to use -xSSE2 because the binary would refuse to run at all otherwise
                        _my_find(_march_flag_list "barcelona" _found)
                        if(NOT _found)
                           _my_find(_march_flag_list "k8-sse3" _found)
                        endif(NOT _found)
                        if(_found)
                           AddCompilerFlag("-xSSE2" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
                        else(_found)
                           AddCompilerFlag("-xSSE3" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
                        endif(_found)
                     else(_found)
                        _my_find(_available_vector_units_list "sse2"   _found)
                        if(_found)
                           AddCompilerFlag("-xSSE2" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
                        endif(_found)
                     endif(_found)
                  endif(_found)
               endif(_found)
            endif(_found)
         endif(_found)
      endif(_found)
   endif(_found)
else() # not ICC => GCC, Clang, Open64
   foreach(_flag ${_march_flag_list})
      AddCompilerFlag("-march=${_flag}" CXX_RESULT _good CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
      if(_good)
         break()
      endif(_good)
   endforeach(_flag)
   foreach(_flag ${_enable_vector_unit_list})
      AddCompilerFlag("-m${_flag}" CXX_RESULT _result)
      if(_result)
         set(_header FALSE)
         if(_flag STREQUAL "sse3")
            set(_header "pmmintrin.h")
         elseif(_flag STREQUAL "ssse3")
            set(_header "tmmintrin.h")
         elseif(_flag STREQUAL "sse4.1")
            set(_header "smmintrin.h")
         elseif(_flag STREQUAL "sse4.2")
            set(_header "smmintrin.h")
         elseif(_flag STREQUAL "sse4a")
            set(_header "ammintrin.h")
         elseif(_flag STREQUAL "avx")
            set(_header "immintrin.h")
         elseif(_flag STREQUAL "avx2")
            set(_header "immintrin.h")
         elseif(_flag STREQUAL "fma4")
            set(_header "x86intrin.h")
         elseif(_flag STREQUAL "xop")
            set(_header "x86intrin.h")
         endif()
         set(_resultVar "HAVE_${_header}")
         string(REPLACE "." "_" _resultVar "${_resultVar}")
         if(_header)
            CHECK_INCLUDE_FILE("${_header}" ${_resultVar} "-m${_flag}")
            if(NOT ${_resultVar})
               set(_useVar "USE_${_flag}")
               string(TOUPPER "${_useVar}" _useVar)
               string(REPLACE "." "_" _useVar "${_useVar}")
               message(STATUS "disabling ${_useVar} because ${_header} is missing")
               set(${_useVar} FALSE)
               list(APPEND _disable_vector_unit_list "${_flag}")
            endif()
         endif()
         if(NOT _header OR ${_resultVar})
            set(CXX_ARCHITECTURE_FLAGS "${CXX_ARCHITECTURE_FLAGS} -m${_flag}")
         endif()
      endif()
   endforeach(_flag)
     foreach(_flag ${_disable_vector_unit_list})
         list(FIND _enable_vector_unit_list ${_flag} _in_enable_list)
         if(NOT ${_in_enable_list})
            AddCompilerFlag("-mno-${_flag}" CXX_FLAGS CXX_ARCHITECTURE_FLAGS)
        endif(NOT ${_in_enable_list})
     endforeach(_flag)
endif()
endmacro(architecture_flags_CXX)

# C stuff
macro(architecture_flags_C _enable_vector_unit_list _available_vector_units_list _march_flag_list _disable_vector_unit_list)
if(CMAKE_C_COMPILER MATCHES "/(icpc|icc)$") # ICC (on Linux)
   _my_find(_available_vector_units_list "avx2"    _found)
   if(_found)
      AddCompilerFlag("-xCORE-AVX2" C_FLAGS C_ARCHITECTURE_FLAGS)
   else(_found)
      _my_find(_available_vector_units_list "f16c"    _found)
      if(_found)
         AddCompilerFlag("-xCORE-AVX-I" C_FLAGS C_ARCHITECTURE_FLAGS)
      else(_found)
         _my_find(_available_vector_units_list "avx"    _found)
         if(_found)
            AddCompilerFlag("-xAVX" C_FLAGS C_ARCHITECTURE_FLAGS)
         else(_found)
            _my_find(_available_vector_units_list "sse4.2" _found)
            if(_found)
               AddCompilerFlag("-xSSE4.2" C_FLAGS C_ARCHITECTURE_FLAGS)
            else(_found)
               _my_find(_available_vector_units_list "sse4.1" _found)
               if(_found)
                  AddCompilerFlag("-xSSE4.1" C_FLAGS C_ARCHITECTURE_FLAGS)
               else(_found)
                  _my_find(_available_vector_units_list "ssse3"  _found)
                  if(_found)
                     AddCompilerFlag("-xSSSE3" C_FLAGS C_ARCHITECTURE_FLAGS)
                  else(_found)
                     _my_find(_available_vector_units_list "sse3"   _found)
                     if(_found)
                        # If the target host is an AMD machine then we still want to use -xSSE2 because the binary would refuse to run at all otherwise
                        _my_find(_march_flag_list "barcelona" _found)
                        if(NOT _found)
                           _my_find(_march_flag_list "k8-sse3" _found)
                        endif(NOT _found)
                        if(_found)
                           AddCompilerFlag("-xSSE2" C_FLAGS C_ARCHITECTURE_FLAGS)
                        else(_found)
                           AddCompilerFlag("-xSSE3" C_FLAGS C_ARCHITECTURE_FLAGS)
                        endif(_found)
                     else(_found)
                        _my_find(_available_vector_units_list "sse2"   _found)
                        if(_found)
                           AddCompilerFlag("-xSSE2" C_FLAGS C_ARCHITECTURE_FLAGS)
                        endif(_found)
                     endif(_found)
                  endif(_found)
               endif(_found)
            endif(_found)
         endif(_found)
      endif(_found)
   endif(_found)
else() # not ICC => GCC, Clang, Open64
   foreach(_flag ${_march_flag_list})
      AddCompilerFlag("-march=${_flag}" C_RESULT _good C_FLAGS C_ARCHITECTURE_FLAGS)
      if(_good)
         break()
      endif(_good)
   endforeach(_flag)
   foreach(_flag ${_enable_vector_unit_list})
      AddCompilerFlag("-m${_flag}" C_RESULT _result)
      if(_result)
         set(_header FALSE)
         if(_flag STREQUAL "sse3")
            set(_header "pmmintrin.h")
         elseif(_flag STREQUAL "ssse3")
            set(_header "tmmintrin.h")
         elseif(_flag STREQUAL "sse4.1")
            set(_header "smmintrin.h")
         elseif(_flag STREQUAL "sse4.2")
            set(_header "smmintrin.h")
         elseif(_flag STREQUAL "sse4a")
            set(_header "ammintrin.h")
         elseif(_flag STREQUAL "avx")
            set(_header "immintrin.h")
         elseif(_flag STREQUAL "avx2")
            set(_header "immintrin.h")
         elseif(_flag STREQUAL "fma4")
            set(_header "x86intrin.h")
         elseif(_flag STREQUAL "xop")
            set(_header "x86intrin.h")
         endif()
         set(_resultVar "HAVE_${_header}")
         string(REPLACE "." "_" _resultVar "${_resultVar}")
         if(_header)
            CHECK_INCLUDE_FILE("${_header}" ${_resultVar} "-m${_flag}")
            if(NOT ${_resultVar})
               set(_useVar "USE_${_flag}")
               string(TOUPPER "${_useVar}" _useVar)
               string(REPLACE "." "_" _useVar "${_useVar}")
               message(STATUS "disabling ${_useVar} because ${_header} is missing")
               set(${_useVar} FALSE)
               list(APPEND _disable_vector_unit_list "${_flag}")
            endif()
         endif()
         if(NOT _header OR ${_resultVar})
            set(C_ARCHITECTURE_FLAGS "${C_ARCHITECTURE_FLAGS} -m${_flag}")
         endif()
      endif()
   endforeach(_flag)
     foreach(_flag ${_disable_vector_unit_list})
         list(FIND _enable_vector_unit_list ${_flag} _in_enable_list)
         if(NOT ${_in_enable_list})
            AddCompilerFlag("-mno-${_flag}" C_FLAGS C_ARCHITECTURE_FLAGS)
        endif(NOT ${_in_enable_list})
     endforeach(_flag)
endif()
endmacro(architecture_flags_C)

# Fortran stuff
macro(architecture_flags_Fortran _enable_vector_unit_list _available_vector_units_list _march_flag_list _disable_vector_unit_list)
if(CMAKE_Fortran_COMPILER MATCHES "ifort") # IFORT (on Linux)
   _my_find(_available_vector_units_list "avx2"    _found)
   if(_found)
      AddCompilerFlag("-xCORE-AVX2" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
   else(_found)
      _my_find(_available_vector_units_list "f16c"    _found)
      if(_found)
         AddCompilerFlag("-xCORE-AVX-I" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
      else(_found)
         _my_find(_available_vector_units_list "avx"    _found)
         if(_found)
            AddCompilerFlag("-xAVX" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
         else(_found)
            _my_find(_available_vector_units_list "sse4.2" _found)
            if(_found)
               AddCompilerFlag("-xSSE4.2" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
            else(_found)
               _my_find(_available_vector_units_list "sse4.1" _found)
               if(_found)
                  AddCompilerFlag("-xSSE4.1" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
               else(_found)
                  _my_find(_available_vector_units_list "ssse3"  _found)
                  if(_found)
                     AddCompilerFlag("-xSSSE3" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
                  else(_found)
                     _my_find(_available_vector_units_list "sse3"   _found)
                     if(_found)
                        # If the target host is an AMD machine then we still want to use -xSSE2 because the binary would refuse to run at all otherwise
                        _my_find(_march_flag_list "barcelona" _found)
                        if(NOT _found)
                           _my_find(_march_flag_list "k8-sse3" _found)
                        endif(NOT _found)
                        if(_found)
                           AddCompilerFlag("-xSSE2" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
                        else(_found)
                           AddCompilerFlag("-xSSE3" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
                        endif(_found)
                     else(_found)
                        _my_find(_available_vector_units_list "sse2"   _found)
                        if(_found)
                           AddCompilerFlag("-xSSE2" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
                        endif(_found)
                     endif(_found)
                  endif(_found)
               endif(_found)
            endif(_found)
         endif(_found)
      endif(_found)
   endif(_found)
elseif(CMAKE_Fortran_COMPILER MATCHES "gfortran") # GFORTRAN 
   foreach(_flag ${_march_flag_list})
      AddCompilerFlag("-march=${_flag}" Fortran_RESULT _good Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
      if(_good)
         break()
      endif(_good)
   endforeach(_flag)
   foreach(_flag ${_enable_vector_unit_list})
      AddCompilerFlag("-m${_flag}" Fortran_RESULT _result)
      if(_result)
         set(_header FALSE)
         if(_flag STREQUAL "sse3")
            set(_header "pmmintrin.h")
         elseif(_flag STREQUAL "ssse3")
            set(_header "tmmintrin.h")
         elseif(_flag STREQUAL "sse4.1")
            set(_header "smmintrin.h")
         elseif(_flag STREQUAL "sse4.2")
            set(_header "smmintrin.h")
         elseif(_flag STREQUAL "sse4a")
            set(_header "ammintrin.h")
         elseif(_flag STREQUAL "avx")
            set(_header "immintrin.h")
         elseif(_flag STREQUAL "avx2")
            set(_header "immintrin.h")
         elseif(_flag STREQUAL "fma4")
            set(_header "x86intrin.h")
         elseif(_flag STREQUAL "xop")
            set(_header "x86intrin.h")
         endif()
         set(_resultVar "HAVE_${_header}")
         string(REPLACE "." "_" _resultVar "${_resultVar}")
         if(_header)
            CHECK_INCLUDE_FILE("${_header}" ${_resultVar} "-m${_flag}")
            if(NOT ${_resultVar})
               set(_useVar "USE_${_flag}")
               string(TOUPPER "${_useVar}" _useVar)
               string(REPLACE "." "_" _useVar "${_useVar}")
               message(STATUS "disabling ${_useVar} because ${_header} is missing")
               set(${_useVar} FALSE)
               list(APPEND _disable_vector_unit_list "${_flag}")
            endif()
         endif()
         if(NOT _header OR ${_resultVar})
            set(Fortran_ARCHITECTURE_FLAGS "${Fortran_ARCHITECTURE_FLAGS} -m${_flag}")
         endif()
      endif()
   endforeach(_flag)
     foreach(_flag ${_disable_vector_unit_list})
         list(FIND _enable_vector_unit_list ${_flag} _in_enable_list)
         if(NOT ${_in_enable_list})
            AddCompilerFlag("-mno-${_flag}" Fortran_FLAGS Fortran_ARCHITECTURE_FLAGS)
        endif(NOT ${_in_enable_list})
     endforeach(_flag)
else() # Other Fortran compilers
     message(STATUS "Unknown Fortran compiler no vectorization flags set!")
endif()
endmacro(architecture_flags_Fortran)
