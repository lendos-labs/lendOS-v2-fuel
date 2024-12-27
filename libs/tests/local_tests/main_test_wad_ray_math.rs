use crate::math::wad_ray_math::{WadRayMath, WAD, HALF_WAD, RAY, HALF_RAY, WAD_RAY_RATIO, MathError};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_constants() {
        assert_eq!(WAD, 1_000_000_000_000_000_000);
        assert_eq!(HALF_WAD, 500_000_000_000_000_000);
        assert_eq!(RAY, 1_000_000_000_000_000_000_000_000_000);
        assert_eq!(HALF_RAY, 500_000_000_000_000_000_000_000_000);
        assert_eq!(WAD_RAY_RATIO, 1_000_000_000);
    }

    #[test]
    fn test_wad_mul() {
        assert_eq!(
            WadRayMath::wad_mul(2_500_000_000_000_000_000, 500_000_000_000_000_000),
            Ok(1_250_000_000_000_000_000)
        );
        assert_eq!(
            WadRayMath::wad_mul(0, 1_000_000_000_000_000_000),
            Ok(0)
        );
        assert_eq!(
            WadRayMath::wad_mul(u256::MAX, 2),
            Err(MathError::MultiplicationOverflow)
        );
    }

    #[test]
    fn test_wad_div() {
        assert_eq!(
            WadRayMath::wad_div(2_500_000_000_000_000_000, 500_000_000_000_000_000),
            Ok(5_000_000_000_000_000_000)
        );
        assert_eq!(
            WadRayMath::wad_div(0, 500_000_000_000_000_000),
            Ok(0)
        );
        assert_eq!(
            WadRayMath::wad_div(1, 0),
            Err(MathError::DivisionByZero)
        );
    }

    #[test]
    fn test_ray_mul() {
        assert_eq!(
            WadRayMath::ray_mul(2_500_000_000_000_000_000_000_000_000, 500_000_000_000_000_000_000_000_000),
            Ok(1_250_000_000_000_000_000_000_000_000)
        );
        assert_eq!(
            WadRayMath::ray_mul(0, 1_000_000_000_000_000_000_000_000_000),
            Ok(0)
        );
        assert_eq!(
            WadRayMath::ray_mul(u256::MAX, 2),
            Err(MathError::MultiplicationOverflow)
        );
    }

    #[test]
    fn test_ray_div() {
        assert_eq!(
            WadRayMath::ray_div(2_500_000_000_000_000_000_000_000_000, 500_000_000_000_000_000_000_000_000),
            Ok(5_000_000_000_000_000_000_000_000_000)
        );
        assert_eq!(
            WadRayMath::ray_div(0, 500_000_000_000_000_000_000_000_000),
            Ok(0)
        );
        assert_eq!(
            WadRayMath::ray_div(1, 0),
            Err(MathError::DivisionByZero)
        );
    }

    #[test]
    fn test_ray_to_wad() {
        assert_eq!(
            WadRayMath::ray_to_wad(1_000_000_000_000_000_000_000_000_000),
            Ok(1_000_000_000_000_000_000)
        );
        assert_eq!(
            WadRayMath::ray_to_wad(0),
            Ok(0)
        );
        assert_eq!(
            WadRayMath::ray_to_wad(u256::MAX),
            Err(MathError::AdditionOverflow)
        );
    }

    #[test]
    fn test_wad_to_ray() {
        assert_eq!(
            WadRayMath::wad_to_ray(1_000_000_000_000_000_000),
            Ok(1_000_000_000_000_000_000_000_000_000)
        );
        assert_eq!(
            WadRayMath::wad_to_ray(0),
            Ok(0)
        );
        assert_eq!(
            WadRayMath::wad_to_ray(u256::MAX),
            Err(MathError::MultiplicationOverflow)
        );
    }
}
