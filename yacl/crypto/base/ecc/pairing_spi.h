// Copyright 2023 Ant Group Co., Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#pragma once

#include "yacl/crypto/base/ecc/ecc_spi.h"
#include "yacl/crypto/base/field/field_spi.h"
#include "yacl/utils/spi/spi_factory.h"

namespace yacl::crypto {

using PairingName = CurveName;
using PairingMeta = CurveMeta;

enum class PairingAlgorithm {
  Weil,
  Tate,
  Ate,
  RAte,
  Eta,
  Atei,
};

// Let $F_{q^k}$ be some finite extension of $F_q$ with $k ≥ 1$. The groups
// $G_1$ and $G_2$ are defined in $E(F_{q^k})$, and the target group $G_T$ is
// defined in the multiplicative group $F_{q^k}^*$ , so we usually write $G_1$
// and $G_2$ additively, whilst we write $G_T$ multiplicatively. Thus, for $P_1,
// P_2 \in G_1$ and $Q_1, Q_2 \in G_2$, the bilinearity of $e$ means that:
// -  e(P_1 + P_2 , Q_1) = e(P_1, Q_1) · e(P_2 , Q_1),
// -  e(P_1, Q_1 + Q_2)  = e(P_1, Q_1) · e(P_1, Q_2),
class PairingGroup {
 public:
  virtual ~PairingGroup() = default;

  virtual PairingName GetPairingName() const = 0;
  virtual PairingAlgorithm GetPairingAlgorithm() const = 0;
  virtual std::string GetLibraryName() const = 0;
  virtual std::string ToString() const = 0;
  virtual size_t GetSecurityStrength() const = 0;

  virtual std::shared_ptr<EcGroup> GetG1() const = 0;
  virtual std::shared_ptr<EcGroup> GetG2() const = 0;
  virtual std::shared_ptr<Field> GetGT() const = 0;

  virtual MPInt GetOrder() const = 0;

  virtual FElement MillerLoop(const EcPoint &group1_point,
                              const EcPoint &group2_point) const = 0;
  virtual FElement FinalExp(const FElement &x) const = 0;
  // pairing = MillerLoop + FinalExponentiation
  virtual FElement Pairing(const EcPoint &group1_point,
                           const EcPoint &group2_point) const = 0;
  // multi_miller_loop

  // multi_pairing
};

// Give pairing meta, return pairing instance.
using PairingCreatorT =
    std::function<std::unique_ptr<PairingGroup>(const PairingMeta &)>;
// Give pairing meta, return whether pairing is supported by this lib.
// True is supported and false is unsupported.
using PairingCheckerT = std::function<bool(const PairingMeta &)>;

class PairingGroupFactory final : public SpiFactoryBase<PairingGroup> {
 public:
  static PairingGroupFactory &Instance();

  /// Register an elliptic curve library
  /// \param lib_name library name, e.g. openssl
  /// \param performance the estimated performance of this lib, bigger is
  /// better
  void Register(const std::string &lib_name, uint64_t performance,
                const PairingCheckerT &checker, const PairingCreatorT &creator);
};

#define REGISTER_PAIRING_LIBRARY(lib_name, performance, checker, creator) \
  REGISTER_SPI_LIBRARY_HELPER(PairingGroupFactory, lib_name, performance, \
                              checker, creator)

}  // namespace yacl::crypto
