#include <catch.hpp>
#include <catch2/benchmark/catch_benchmark.hpp>
#include <memory_resource>

inline constexpr auto ITERATIONS = 1024 * 1024 * 1;


template<typename T>
using vec_type = std::pmr::list<T>;

TEST_CASE("vector with pmr default memory resource", "[vector]")
{
    BENCHMARK_ADVANCED("push_back")(Catch::Benchmark::Chronometer meter)
    {
        vec_type<int> v;
        meter.measure([&] {
            for(int i = 0; i < ITERATIONS; ++i)
            {
                v.push_back(i);
            }

            return v.size();
        });
    };

    BENCHMARK_ADVANCED("emplace_back")(Catch::Benchmark::Chronometer meter)
    {
        vec_type<int> v;
        meter.measure([&] {
            for(int i = 0; i < ITERATIONS; ++i)
            {
                v.emplace_back(i);
            }
            return v.size();
        });
    };
}

TEST_CASE("vector with pmr monotonic memory resource", "[vector]")
{

    BENCHMARK_ADVANCED("push_back")(Catch::Benchmark::Chronometer meter)
    {
        std::vector<int>                    buffer(ITERATIONS * 2);
        std::pmr::monotonic_buffer_resource r(buffer.data(), buffer.size() * sizeof(int));
        vec_type<int>                       v(&r);

        meter.measure([&] {
            for(int i = 0; i < ITERATIONS; ++i)
            {
                v.push_back(i);
            }

            return v.size();
        });
    };

    BENCHMARK_ADVANCED("emplace_back")(Catch::Benchmark::Chronometer meter)
    {
        std::vector<int>                    buffer(ITERATIONS * 2);
        std::pmr::monotonic_buffer_resource r(buffer.data(), buffer.size() * sizeof(int));
        vec_type<int>                       v(&r);
        meter.measure([&] {
            for(int i = 0; i < ITERATIONS; ++i)
            {
                v.emplace_back(i);
            }
            return v.size();
        });
    };
}