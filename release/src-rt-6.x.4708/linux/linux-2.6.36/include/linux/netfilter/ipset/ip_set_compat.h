#ifndef __IP_SET_COMPAT_H
#define __IP_SET_COMPAT_H

/* Not everything could be moved here. Compatibility stuffs can be found in
 * xt_set.c, ip_set_core.c, ip_set_getport.c, pfxlen.c too.
 */

#define HAVE_STRUCT_XT_ACTION_PARAM
#define HAVE_VZALLOC
#undef HAVE_ETHER_ADDR_EQUAL
#undef HAVE_NLA_PUT_BE16
#undef HAVE_NLA_PUT_BE64
#undef HAVE_NLA_PUT_64BIT
#undef HAVE_NL_INFO_PORTID
#define HAVE_NETLINK_DUMP_START_ARGS	5
#undef HAVE_NS_CAPABLE
#undef HAVE_NFNL_LOCK_SUBSYS
#undef HAVE_EXPORT_H
#define HAVE_IPV6_SKIP_EXTHDR_ARGS	3
#undef HAVE_CHECKENTRY_BOOL
#undef HAVE_XT_TARGET_PARAM
#define HAVE_NET_OPS_ID
#undef HAVE_USER_NS_IN_STRUCT_NET
#undef HAVE_RBTREE_POSTORDER_FOR_EACH_ENTRY_SAFE
#define HAVE_KVFREE
#define HAVE_XT_MTCHK_PARAM_STRUCT_NET
#undef HAVE_TCF_EMATCH_OPS_CHANGE_ARG_NET
#undef HAVE_TCF_EMATCH_STRUCT_NET
#undef HAVE_LIST_LAST_ENTRY
#undef HAVE_LIST_NEXT_ENTRY
#undef HAVE_ETHER_ADDR_COPY
#undef HAVE_NF_BRIDGE_GET_PHYSDEV
#undef HAVE_NLA_PUT_IN_ADDR
#undef HAVE_NET_IN_NFNL_CALLBACK_FN
#define HAVE_EXPORT_SYMBOL_GPL_IN_MODULE_H
#undef HAVE_TC_SKB_PROTOCOL
#undef HAVE_NET_IN_XT_ACTION_PARAM

#ifdef HAVE_EXPORT_SYMBOL_GPL_IN_MODULE_H
#include <linux/module.h>
#endif

#ifdef HAVE_EXPORT_H
#include <linux/export.h>
#endif

#ifndef IP_SET_COMPAT_HEADERS

#ifndef CONFIG_IP_SET_MAX
#ifdef IP_SET_MAX
#define CONFIG_IP_SET_MAX	IP_SET_MAX
#else
#define CONFIG_IP_SET_MAX	256
#endif
#endif

#ifndef IS_ENABLED
#define __X_ARG_PLACEHOLDER_1 0,
#define x_config_enabled(cfg) _x_config_enabled(cfg)
#define _x_config_enabled(value) __x_config_enabled(__X_ARG_PLACEHOLDER_##value)
#define __x_config_enabled(arg1_or_junk) ___x_config_enabled(arg1_or_junk 1, 0)
#define ___x_config_enabled(__ignored, val, ...) val

#define IS_ENABLED(option) \
	(x_config_enabled(option) || x_config_enabled(option##_MODULE))
#endif

#include <linux/version.h>
#include <linux/netlink.h>

#ifndef rcu_dereference_bh
#define rcu_dereference_bh(p)		rcu_dereference(p)
#endif

#ifndef rcu_dereference_protected
#define rcu_dereference_protected(p, c)	(p)
#endif

#ifndef rcu_dereference_bh_check
#define rcu_dereference_bh_check(p, c)	rcu_dereference_bh(p)
/*#define rcu_dereference_bh_check(p, c) \
	__rcu_dereference_check((p), rcu_read_lock_bh_held() || (c), __rcu) */
#endif

#ifndef __rcu
#define	__rcu
#ifndef RCU_INIT_POINTER
/*
#define RCU_INIT_POINTER(p, v) \
	do { \
		p = v; \
	} while (0)
*/
#define RCU_INIT_POINTER(p, v) \
	do { \
		p = (typeof(*v) __force __rcu *)(v); \
	} while (0)
#endif
#else

#ifndef RCU_INITIALIZER
#define RCU_INITIALIZER(v)	(typeof(*(v)) __force __rcu *)(v)
#endif
#ifndef RCU_INIT_POINTER
#define RCU_INIT_POINTER(p, v) \
	do { \
		p = RCU_INITIALIZER(v); \
	} while (0)
#endif
#endif

#ifndef kfree_rcu
static inline void kfree_call_rcu(struct rcu_head *head,
				  void (*func)(struct rcu_head *rcu))
{
	call_rcu(head, func);
}

#define __is_kfree_rcu_offset(offset) ((offset) < 4096)

#define __kfree_rcu(head, offset) \
	do { \
		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
		kfree_call_rcu(head, (void (*)(struct rcu_head *))(unsigned long)(offset)); \
	} while (0)

#define kfree_rcu(ptr, rcu_head) \
	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
#endif

#ifdef CHECK_KCONFIG
#ifndef CONFIG_SPARSE_RCU_POINTER
#error "CONFIG_SPARSE_RCU_POINTER must be enabled"
#endif
#endif

#if defined(CONFIG_NETFILTER_NETLINK) || defined(CONFIG_NETFILTER_NETLINK_MODULE)
#else
#error "NETFILTER_NETLINK must be enabled: select NFACCT/NFQUEUE/LOG over NFNETLINK"
#endif

#ifndef HAVE_STRUCT_XT_ACTION_PARAM
#define xt_action_param		xt_match_param
#endif

#ifndef HAVE_VZALLOC
#define vzalloc(size)		__vmalloc(size,\
					  GFP_KERNEL|__GFP_ZERO|__GFP_HIGHMEM,\
					  PAGE_KERNEL)
#endif

#ifndef HAVE_ETHER_ADDR_EQUAL
#include <linux/etherdevice.h>

static inline bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
{
	return !compare_ether_addr(addr1, addr2);
}
#endif

#ifndef HAVE_NLA_PUT_BE64
static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value)
{
	return nla_put(skb, attrtype, sizeof(__be64), &value);
}

static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
{
	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value);
}
#endif

#ifdef HAVE_NLA_PUT_64BIT
#define IPSET_NLA_PUT_NET64(skb, t, v, pa) nla_put_net64(skb, t, v, pa)
#else
#define IPSET_NLA_PUT_NET64(skb, t, v, pa) nla_put_net64(skb, t, v)
#endif

#ifdef HAVE_NL_INFO_PORTID
#define NETLINK_PORTID(skb)	NETLINK_CB(skb).portid
#else
#define NETLINK_PORTID(skb)	NETLINK_CB(skb).pid
#endif

#ifndef HAVE_USER_NS_IN_STRUCT_NET
#define ns_capable(ns, cap)	capable(cap)
#endif

#ifndef HAVE_NFNL_LOCK_SUBSYS
#define nfnl_lock(x)		nfnl_lock()
#define nfnl_unlock(x)		nfnl_unlock()
#endif

#if HAVE_IPV6_SKIP_EXTHDR_ARGS == 3
#define ipv6_skip_exthdr(skbuff, start, nexthdrp, frag_offp)	\
	ipv6_skip_exthdr(skbuff, start, nexthdrp)
#endif

#ifndef HAVE_KVFREE
#include <linux/vmalloc.h>
static inline void kvfree(const void *addr)
{
	if (is_vmalloc_addr(addr))
		vfree(addr);
	else
		kfree(addr);
}
#endif

#ifndef HAVE_NLA_PUT_BE16
static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
{
	return nla_put(skb, attrtype, sizeof(__be16), &value);
}

static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
{
	return nla_put_be16(skb, attrtype | NLA_F_NET_BYTEORDER, value);
}

static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
{
	return nla_put(skb, attrtype, sizeof(__be32), &value);
}

static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
{
	return nla_put_be32(skb, attrtype | NLA_F_NET_BYTEORDER, value);
}
#endif

#ifndef HAVE_LIST_LAST_ENTRY
#define list_last_entry(ptr, type, member) \
	list_entry((ptr)->prev, type, member)
#endif
#ifndef HAVE_LIST_NEXT_ENTRY
#define list_next_entry(pos, member)	\
	list_entry((pos)->member.next, typeof(*(pos)), member)
#define list_prev_entry(pos, member)	\
	list_entry((pos)->member.prev, typeof(*(pos)), member)
#endif

#ifndef HAVE_ETHER_ADDR_COPY
#define ether_addr_copy(dst, src)	memcpy(dst, src, ETH_ALEN)
#endif

#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
#ifndef HAVE_NF_BRIDGE_GET_PHYSDEV
static inline struct net_device *
nf_bridge_get_physindev(const struct sk_buff *skb)
{
	return skb->nf_bridge ? skb->nf_bridge->physindev : NULL;
}

static inline struct net_device *
nf_bridge_get_physoutdev(const struct sk_buff *skb)
{
	return skb->nf_bridge ? skb->nf_bridge->physoutdev : NULL;
}
#endif
#endif

#ifndef HAVE_NLA_PUT_IN_ADDR
static inline int nla_put_in_addr(struct sk_buff *skb, int attrtype,
				  __be32 addr)
{
	return nla_put_be32(skb, attrtype, addr);
}

static inline int nla_put_in6_addr(struct sk_buff *skb, int attrtype,
				   const struct in6_addr *addr)
{
	return nla_put(skb, attrtype, sizeof(*addr), addr);
}
#endif

#ifdef HAVE_NET_IN_NFNL_CALLBACK_FN
#define IPSET_CBFN(fn, net, nl, skb, nlh, cda)	fn(net, nl, skb, nlh, cda)
#define IPSET_SOCK_NET(net, ctnl)		net
#else
#define IPSET_CBFN(fn, net, nl, skb, nlh, cda)	fn(nl, skb, nlh, cda)
#define IPSET_SOCK_NET(net, ctnl)		sock_net(ctnl)
#endif

#ifndef HAVE_TC_SKB_PROTOCOL
#include <linux/if_vlan.h>
static inline __be16 tc_skb_protocol(const struct sk_buff *skb)
{
/*
	if (vlan_tx_tag_present(skb))
		return skb->vlan_proto;
*/
	return skb->protocol;
}
#endif

#ifdef HAVE_NET_IN_XT_ACTION_PARAM
#define IPSET_DEV_NET(par)	(par)->net
#else
#define IPSET_DEV_NET(par)	dev_net((par)->in ? (par)->in : (par)->out)
#endif

#ifndef smp_mb__before_atomic
#define smp_mb__before_atomic()	smp_mb()
#define smp_mb__after_atomic()	smp_mb()
#endif

#ifndef pr_warn
#define pr_warn	pr_warning
#endif

#ifndef SIZE_MAX
#define SIZE_MAX	(~(size_t)0)
#endif

#endif /* IP_SET_COMPAT_HEADERS */
#endif /* __IP_SET_COMPAT_H */
