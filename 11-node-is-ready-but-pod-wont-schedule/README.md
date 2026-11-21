# Node is ready, but pods won't schedule

## Problem
- `node-02` is back from a kernel upgrade, but still show `Ready,SchedulingDisabled`.
    ![alt text](image.png)

- the Pods that can only run on it are stuck in Pending. 
    ![alt text](image-1.png)

## How to solve
- The Node is not available for scheduling, maybe, the reason is the Node isn't `uncordon`. Let try to see if it fix the problem -> it's now available for scheduling

    ![alt text](image-2.png)

- But the pod is still in `Pending` state

    ![alt text](image-3.png)

  + Let describe the node and see if there is any problem -> There is a `Taints` that prevent the normal Pods to be scheduled (**only Pod that has a matching Toleration)
      - **Pods already running on the node will continue running**

    ![alt text](image-4.png)

      - One solution is is adding a toleration to the Pod specification

        ```shell
        spec:
          tolerations:
            - key: "maintenance"
              operator: "Equal"
              value: "kernel-upgrade"
              effect: "NoSchedule"
        ```

      - Or remove the taint using this command `kubectl taint nodes <node-name> maintenance=kernel-upgrade:NoSchedule-` -> Now Node has no Taints and Pods can be scheduled in this node

          ![alt text](image-5.png)
