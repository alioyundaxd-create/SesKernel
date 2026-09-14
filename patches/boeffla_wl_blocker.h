/*
 * Boeffla Wakelock Blocker Driver for Linux 4.14 (SM7150)
 *
 * Copyright (C) 2015-2018 Andi P. (Lord Boeffla)
 * Adapted for SM7150 / Galaxy M51
 */

#ifndef _LINUX_BOEFFLA_WL_BLOCKER_H
#define _LINUX_BOEFFLA_WL_BLOCKER_H

#include <linux/types.h>

#define BOEFFLA_WL_BLOCKER_VERSION "1.1.0"

#ifdef CONFIG_BOEFFLA_WL_BLOCKER
extern bool is_boeffla_wl_blocker_active(void);
extern bool is_boeffla_wl_blocked(const char *name);
#else
static inline bool is_boeffla_wl_blocker_active(void) { return false; }
static inline bool is_boeffla_wl_blocked(const char *name) { return false; }
#endif

#endif /* _LINUX_BOEFFLA_WL_BLOCKER_H */
