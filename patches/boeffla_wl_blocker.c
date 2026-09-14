/*
 * Boeffla Wakelock Blocker Driver for Linux 4.14
 *
 * Copyright (C) 2015-2018 Andi P. (Lord Boeffla)
 * Adapted for SM7150 / Galaxy M51 Custom Kernel
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/types.h>
#include <linux/string.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/mutex.h>
#include <linux/uaccess.h>
#include "boeffla_wl_blocker.h"

#define WL_BLOCKER_BUF_SIZE 2048

static char wl_blocked_list[WL_BLOCKER_BUF_SIZE] = "qcom_rx_wakelock;wlan;wlan_wow_wl;wlan_extscan_wl;netmgr_wl;IPA_WS;sensor_ind;wcnss_filter_lock";
static DEFINE_MUTEX(wl_blocker_mutex);
static bool wl_blocker_debug = false;

bool is_boeffla_wl_blocker_active(void)
{
	return (wl_blocked_list[0] != '\0');
}
EXPORT_SYMBOL(is_boeffla_wl_blocker_active);

bool is_boeffla_wl_blocked(const char *name)
{
	char *list_copy;
	char *token;
	char *cur;
	bool blocked = false;

	if (!name || wl_blocked_list[0] == '\0')
		return false;

	list_copy = kstrdup(wl_blocked_list, GFP_ATOMIC);
	if (!list_copy)
		return false;

	cur = list_copy;
	while ((token = strsep(&cur, ";")) != NULL) {
		if (*token == '\0')
			continue;
		if (strcmp(name, token) == 0) {
			blocked = true;
			if (wl_blocker_debug)
				pr_info("boeffla_wl_blocker: BLOCKED wakelock '%s'\n", name);
			break;
		}
	}

	kfree(list_copy);
	return blocked;
}
EXPORT_SYMBOL(is_boeffla_wl_blocked);

/* Sysfs attributes */
static ssize_t wakelock_blocker_show(struct device *dev,
				      struct device_attribute *attr, char *buf)
{
	ssize_t ret;
	mutex_lock(&wl_blocker_mutex);
	ret = snprintf(buf, PAGE_SIZE, "%s\n", wl_blocked_list);
	mutex_unlock(&wl_blocker_mutex);
	return ret;
}

static ssize_t wakelock_blocker_store(struct device *dev,
				       struct device_attribute *attr,
				       const char *buf, size_t count)
{
	size_t len = count;

	if (len >= WL_BLOCKER_BUF_SIZE)
		len = WL_BLOCKER_BUF_SIZE - 1;

	mutex_lock(&wl_blocker_mutex);
	strncpy(wl_blocked_list, buf, len);
	wl_blocked_list[len] = '\0';

	/* Sondaki newline karakterini temizle */
	if (len > 0 && wl_blocked_list[len - 1] == '\n')
		wl_blocked_list[len - 1] = '\0';
	mutex_unlock(&wl_blocker_mutex);

	return count;
}

static DEVICE_ATTR_RW(wakelock_blocker);

static ssize_t debug_show(struct device *dev,
			  struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", wl_blocker_debug ? 1 : 0);
}

static ssize_t debug_store(struct device *dev,
			   struct device_attribute *attr,
			   const char *buf, size_t count)
{
	int val;
	if (sscanf(buf, "%d", &val) == 1)
		wl_blocker_debug = (val != 0);
	return count;
}

static DEVICE_ATTR_RW(debug);

static ssize_t version_show(struct device *dev,
			    struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%s\n", BOEFFLA_WL_BLOCKER_VERSION);
}

static DEVICE_ATTR_RO(version);

static struct attribute *boeffla_wl_blocker_attrs[] = {
	&dev_attr_wakelock_blocker.attr,
	&dev_attr_debug.attr,
	&dev_attr_version.attr,
	NULL,
};

static const struct attribute_group boeffla_wl_blocker_group = {
	.attrs = boeffla_wl_blocker_attrs,
};

static const struct attribute_group *boeffla_wl_blocker_groups[] = {
	&boeffla_wl_blocker_group,
	NULL,
};

static struct miscdevice boeffla_wl_blocker_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = "boeffla_wakelock_blocker",
	.groups = boeffla_wl_blocker_groups,
};

int __init boeffla_wl_blocker_init(void)
{
	int ret;

	ret = misc_register(&boeffla_wl_blocker_dev);
	if (ret) {
		pr_err("boeffla_wl_blocker: failed to register misc device\n");
		return ret;
	}

	pr_info("boeffla_wl_blocker: driver version %s initialized\n", BOEFFLA_WL_BLOCKER_VERSION);
	return 0;
}

void __exit boeffla_wl_blocker_exit(void)
{
	misc_deregister(&boeffla_wl_blocker_dev);
}

module_init(boeffla_wl_blocker_init);
module_exit(boeffla_wl_blocker_exit);

MODULE_AUTHOR("Andi P. (Lord Boeffla)");
MODULE_DESCRIPTION("Boeffla Wakelock Blocker Driver");
MODULE_LICENSE("GPL v2");
