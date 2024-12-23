library;

use std::u256::*;
mod wad_ray_math;
use wad_ray_math::{WadRayMath, RAY, MathError};

const SECONDS_PER_YEAR: u256 = 365 * 24 * 60 * 60; // 365 days

pub struct MathUtils {}

impl MathUtils {
    #[storage(read)]
    fn math_utils_calculate_linear_interest(rate: u256, last_update_timestamp: u64) -> u256 {
        let mut result = rate * (std::block::timestamp().as_u256() - U256::try_from(last_update_timestamp).unwrap());
        result = result / SECONDS_PER_YEAR;
        RAY + result
    }

    fn math_utils_calculate_compounded_interest(rate: u256, last_update_timestamp: u64, current_timestamp: u256) -> u256 {
        let exp = current_timestamp - U256::try_from(last_update_timestamp).unwrap();
        if exp == 0 {
            return RAY;
        }
        let mut exp_minus_one = 0;
        let mut exp_minus_two = 0;
        let mut base_power_two = 0;
        let mut base_power_three = 0;
        exp_minus_one = exp - 1;
        exp_minus_two = if exp > 2 {
            exp - 2
        } else {
            0
        };
        base_power_two = WadRayMath::ray_mul(rate, rate) / (SECONDS_PER_YEAR * SECONDS_PER_YEAR);
        base_power_three = WadRayMath::ray_mul(base_power_two, rate) / SECONDS_PER_YEAR;
        let mut second_term = exp * exp_minus_one * base_power_two;
        second_term /= 2;
        let mut third_term = exp * exp_minus_one * exp_minus_two * base_power_three;
        third_term /= 6;
        RAY + (rate * exp) / SECONDS_PER_YEAR + second_term + third_term
    }

    #[storage(read)]
    fn math_utils_calculate_compounded_interest_2(rate: u256, last_update_timestamp: u64) -> u256 {
        math_utils_calculate_compounded_interest(rate, last_update_timestamp, std::block::timestamp().as_u256())
    }
}
