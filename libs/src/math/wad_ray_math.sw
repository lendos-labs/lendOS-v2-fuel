library;

pub const WAD: u256 = 1_000_000_000_000_000_000_u256; // 1e18
pub const HALF_WAD: u256 = 500_000_000_000_000_000_u256; // 0.5e18
pub const RAY: u256 = 1_000_000_000_000_000_000_000_000_000_u256; // 1e27
pub const HALF_RAY: u256 = 500_000_000_000_000_000_000_000_000_u256; // 0.5e27
pub const WAD_RAY_RATIO: u256 = 1_000_000_000_u256; // 1e9

/// WadRayMath library provides functions to perform calculations with Wad and Ray units
/// Wad: decimal numbers with 18 digits of precision
/// Ray: decimal numbers with 27 digits of precision
pub struct WadRayMath {}

/// Error messages for math operations
pub enum MathError {
    MultiplicationOverflow: (),
    DivisionByZero: (),
    AdditionOverflow: (),
}

impl WadRayMath {
    /// Multiplies two wad, rounding half up to the nearest wad
    /// @param a Wad
    /// @param b Wad
    /// @return The result of a*b, in wad
    pub fn wad_mul(a: u256, b: u256) -> Result<u256, MathError> {
        if a == 0 || b == 0 {
            return Ok(0);
        }

        // Check for overflow: a <= (type(u256).max - HALF_WAD) / b
        let max_value = u256::max() - Self::HALF_WAD;
        if a > max_value / b {
            return Err(MathError::MultiplicationOverflow);
        }

        Ok((a * b + Self::HALF_WAD) / Self::WAD)
    }

    /// Draft asm version
    /// Multiplies two wad, rounding half up to the nearest wad
    pub fn asm_wad_mul(a: u256, b: u256) -> u256 {
        let mut c: u256 = 0;

        asm(a: a, b: b, half_wad: HALF_WAD, wad: WAD, r: c) {
            // Initialize zero register
            movi r0, 0

            // Check if b is zero using 256-bit comparison
            wqcm r1, b, r0
            jnzi r1, 15    // Jump to rvrt instruction if r1 is not zero (15 instructions forward)

            // Calculate (type(u256).max - HALF_WAD)
            not r2, r0     
            wqam r3, r2, half_wad

            // Divide by b to get the maximum allowed value for a
            wqdv r4, r3, b

            // Compare a with max allowed value
            wqcm r5, a, r4
            gt r6, r5, r0
            jnzi r6, 8     // Jump to rvrt instruction if r6 is not zero (8 instructions forward)

            // Perform multiplication: c = (a * b + HALF_WAD) / WAD
            wqml r7, a, b    
            wqam r8, r7, half_wad  
            wqdv r9, r8, wad  

            move r, r9
            ret

            // Revert instruction
            rvrt r0
        }
        c
    }

    /// Divides two wad, rounding half up to the nearest wad
    /// @param a Wad
    /// @param b Wad
    /// @return The result of a/b, in wad
    pub fn wad_div(a: u256, b: u256) -> Result<u256, MathError> {
        if b == 0 {
            return Err(MathError::DivisionByZero);
        }

        let half_b = b / 2;
        let max_value = u256::max() - half_b;
        
        if a > max_value / Self::WAD {
            return Err(MathError::MultiplicationOverflow);
        }

        Ok((a * Self::WAD + half_b) / b)
    }

    /// Multiplies two ray, rounding half up to the nearest ray
    /// @param a Ray
    /// @param b Ray
    /// @return The result of a*b, in ray
    pub fn ray_mul(a: u256, b: u256) -> Result<u256, MathError> {
        if a == 0 || b == 0 {
            return Ok(0);
        }

        let max_value = u256::max() - Self::HALF_RAY;
        if a > max_value / b {
            return Err(MathError::MultiplicationOverflow);
        }

        Ok((a * b + Self::HALF_RAY) / Self::RAY)
    }

    /// Divides two ray, rounding half up to the nearest ray
    /// @param a Ray
    /// @param b Ray
    /// @return The result of a/b, in ray
    pub fn ray_div(a: u256, b: u256) -> Result<u256, MathError> {
        if b == 0 {
            return Err(MathError::DivisionByZero);
        }

        let half_b = b / 2;
        let max_value = u256::max() - half_b;
        
        if a > max_value / Self::RAY {
            return Err(MathError::MultiplicationOverflow);
        }

        Ok((a * Self::RAY + half_b) / b)
    }

    /// Casts ray down to wad
    /// @param a Ray
    /// @return a casted to wad, rounded half up to the nearest wad
    pub fn ray_to_wad(a: u256) -> Result<u256, MathError> {
        let half_ratio = Self::WAD_RAY_RATIO / 2;
        let result = half_ratio + a;
        
        if result < half_ratio {
            return Err(MathError::AdditionOverflow);
        }

        Ok(result / Self::WAD_RAY_RATIO)
    }

    /// Converts wad up to ray
    /// @param a Wad
    /// @return a converted in ray
    pub fn wad_to_ray(a: u256) -> Result<u256, MathError> {
        let result = a * Self::WAD_RAY_RATIO;
        
        if result / Self::WAD_RAY_RATIO != a {
            return Err(MathError::MultiplicationOverflow);
        }

        Ok(result)
    }
}
